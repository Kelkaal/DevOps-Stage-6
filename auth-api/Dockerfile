# Build Stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy go.mod and go.sum to leverage Docker cache
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o auth-api .

# Final Stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the built binary from the builder stage
COPY --from=builder /app/auth-api .

RUN chmod +x ./auth-api

# Expose port (will be mapped in docker-compose.yml)
EXPOSE 8080

# Command to run the application
CMD ["./auth-api"]
