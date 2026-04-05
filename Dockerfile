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

# Define build arguments for UID/GID
ARG USER_ID=1000
ARG GROUP_ID=1000

# Create the group and user with specific IDs
RUN addgroup -g ${GROUP_ID} fleet && \
    adduser -D -u ${USER_ID} -G fleet fleet && \
    mkdir -p /logs /data /vulndb && \
    chown -R fleet:fleet /logs /data /vulndb

USER fleet
WORKDIR /home/fleet

# 3. Copy the binary
COPY --from=builder /app/fleet /usr/bin/fleet

# 4. Set the entrypoint
CMD ["fleet", "serve"]
