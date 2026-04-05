# Stage 1: Build the binary
FROM golang:1.26.1-alpine AS builder

# 1. Install only what we need for the Go build
RUN apk add --no-cache make git

WORKDIR /app
COPY . .

# 2. Grab the pre-generated bindata files from the official image
# This replaces the 'placeholder.go' with the actual UI assets
COPY --from=fleetdm/fleet:latest /app/server/bindata/bindata.go ./server/bindata/bindata.go

# 3. Build the binary (no 'make assets' or 'npm' required!)
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
