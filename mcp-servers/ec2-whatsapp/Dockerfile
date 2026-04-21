FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package.json ./

# Install dependencies
RUN npm install --production

# Copy application code
COPY index.js ./

# Default command
CMD ["node", "index.js"]
