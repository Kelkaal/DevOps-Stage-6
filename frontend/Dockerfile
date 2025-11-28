# Build Stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package.json and package-lock.json to leverage Docker cache
COPY package.json package-lock.json ./
RUN apk add --no-cache python3 make g++
ENV PYTHON=/usr/bin/python3
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
