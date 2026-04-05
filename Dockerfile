# Stage 1: Build the binary
FROM golang:1.21-alpine AS builder

# Install build dependencies
RUN apk add --no-cache make git

WORKDIR /app

# Copy the source code
COPY . .

# Compile the fleet binary
# Note: You might need to adjust this depending on Fleet's specific build flags
RUN go build -o fleet ./cmd/fleet

# Stage 2: Create the final image
FROM alpine:latest

# Create a non-root user for security
RUN adduser -D fleet
USER fleet

WORKDIR /home/fleet

# Copy the binary from the builder stage
COPY --from=builder /app/fleet /usr/bin/fleet

# Set the entrypoint
CMD ["fleet", "serve"]
