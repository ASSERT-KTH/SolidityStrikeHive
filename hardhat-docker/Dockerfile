# Use Node.js as the base image
FROM node:20

# Set working directory
WORKDIR /usr/src/app

# Install Hardhat globally
RUN npm install -g hardhat

# Install necessary dependencies
COPY package.json ./
COPY package-lock.json ./
COPY hardhat.config.js ./
RUN npm install

# Create folders for contracts and tests
RUN mkdir -p contracts test

# Entry point script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Run the entrypoint script on container start
ENTRYPOINT ["/entrypoint.sh"]
