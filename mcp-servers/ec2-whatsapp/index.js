#!/usr/bin/env node

/**
 * EC2 WhatsApp Bot Management MCP Server
 * 
 * Provides tools to view and manage WhatsApp bot instances running on EC2 remote server.
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import { exec } from "child_process";
import { promisify } from "util";

const execAsync = promisify(exec);

// Configuration from environment variables
const EC2_HOST = process.env.EC2_HOST || "";
const EC2_USER = process.env.EC2_USER || "ec2-user";
const EC2_KEY_FILE = process.env.EC2_KEY_FILE || "/opt/keys/ec2-whatsapp.pem";
const SCRIPTS_DIR = "/home/ec2-user/scripts";

if (!EC2_HOST) {
  console.error("Error: EC2_HOST environment variable is required");
  process.exit(1);
}

const server = new Server(
  {
    name: "ec2-whatsapp-mcp",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Define available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "view_whatsapp_bots",
        description: "View running WhatsApp bot processes on EC2. Optionally filter by environment (stg/prd).",
        inputSchema: {
          type: "object",
          properties: {
            environment: {
              type: "string",
              enum: ["stg", "prd"],
              description: "Filter by environment. If not specified, shows all environments.",
            },
          },
          required: [],
        },
      },
      {
        name: "update_whatsapp_bot",
        description: "Update/restart a WhatsApp bot instance. Removes old script, deploys new version, and starts the bot.",
        inputSchema: {
          type: "object",
          properties: {
            environment: {
              type: "string",
              enum: ["stg", "prd"],
              description: "Target environment (required)",
            },
            mobile: {
              type: "string",
              description: "Phone number with country code, no + prefix (e.g., 6587654321) (required)",
            },
            email: {
              type: "string",
              format: "email",
              description: "Email associated with the bot account (required)",
            },
          },
          required: ["environment", "mobile", "email"],
        },
      },
    ],
  };
});

// Handle tool execution
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    if (name === "view_whatsapp_bots") {
      return await handleViewBots(args);
    } else if (name === "update_whatsapp_bot") {
      return await handleUpdateBot(args);
    } else {
      throw new Error(`Unknown tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `Error: ${error.message}`,
        },
      ],
      isError: true,
    };
  }
});

async function handleViewBots(args) {
  const { environment } = args || {};
  
  let command = `cd ${SCRIPTS_DIR} && ./view.sh`;
  if (environment) {
    command += ` ${environment}`;
  }

  const sshCommand = buildSSHCommand(command);
  
  try {
    const { stdout, stderr } = await execAsync(sshCommand);
    
    return {
      content: [
        {
          type: "text",
          text: stdout || stderr || "No output received",
        },
      ],
    };
  } catch (error) {
    throw new Error(`Failed to view bots: ${error.message}`);
  }
}

async function handleUpdateBot(args) {
  const { environment, mobile, email } = args;

  if (!environment || !mobile || !email) {
    throw new Error("Missing required parameters: environment, mobile, email");
  }

  const command = `cd ${SCRIPTS_DIR} && ./update.sh -env=${environment} -mobile=${mobile} -email=${email}`;
  const sshCommand = buildSSHCommand(command);

  try {
    const { stdout, stderr } = await execAsync(sshCommand);
    
    // After update, automatically verify the bot started
    const verifyCommand = buildSSHCommand(`cd ${SCRIPTS_DIR} && ./view.sh ${environment}`);
    const { stdout: verifyOutput } = await execAsync(verifyCommand);

    return {
      content: [
        {
          type: "text",
          text: `Update completed:\n${stdout || stderr}\n\nVerification:\n${verifyOutput}`,
        },
      ],
    };
  } catch (error) {
    throw new Error(`Failed to update bot: ${error.message}`);
  }
}

function buildSSHCommand(remoteCommand) {
  return `ssh -i ${EC2_KEY_FILE} -o StrictHostKeyChecking=no -o BatchMode=yes ${EC2_USER}@${EC2_HOST} "${remoteCommand}"`;
}

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("EC2 WhatsApp MCP Server running on stdio");
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
