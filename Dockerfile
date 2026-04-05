# Stage 1: Build the binary
FROM golang:1.26.1-alpine AS builder

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

# 1. Create the user and the required directory
RUN adduser -D fleet && \
    mkdir -p /logs && \
    chown -f fleet:fleet /logs

# 2. Switch to the fleet user
USER fleet
WORKDIR /home/fleet

# 3. Copy the binary
COPY --from=builder /app/fleet /usr/bin/fleet

# 4. Set the entrypoint
CMD ["fleet", "serve"]
