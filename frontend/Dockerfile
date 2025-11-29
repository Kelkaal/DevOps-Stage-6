# Build Stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package.json and package-lock.json. The lock file may need to be deleted
# from the repository if it causes issues with the new dependencies.
COPY package.json package-lock.json* ./

# Install dependencies. This is now much simpler.
RUN npm install

# Copy the rest of the source code
COPY . .

# Build the application
RUN npm run build

# Final Stage
FROM nginx:stable-alpine

# Copy the custom Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built application from the builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80
