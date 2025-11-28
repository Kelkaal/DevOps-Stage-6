FROM node:18-alpine

WORKDIR /app

# Copy package.json and package-lock.json to leverage Docker cache
COPY package.json package-lock.json ./
RUN npm install

# Copy the rest of the source code
COPY . .

# Expose the port the app runs on
EXPOSE 8082

# Command to run the application
CMD ["node", "server.js"]
