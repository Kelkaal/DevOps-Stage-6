# Build Stage
FROM maven:3.8.7-openjdk-18-slim AS builder

WORKDIR /app

# Copy the source code
COPY . .

# Build the application. This command also downloads dependencies.
RUN mvn package -Dmaven.test.skip=true

# Final Stage
FROM eclipse-temurin:18-jre-alpine

WORKDIR /app

# Copy the built JAR file from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose port
EXPOSE 8083

# Command to run the application
ENTRYPOINT ["java", "--add-opens", "java.base/java.lang=ALL-UNNAMED", "-jar", "app.jar"]
