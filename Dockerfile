# STAGE 1: Build YOUR Custom Backend Logic
FROM golang:1.23-alpine AS builder

# Install the C-toolchain required for CGO (SQLite, etc.)
RUN apk add --no-cache make git gcc musl-dev libc-dev

WORKDIR /app
COPY . .

# Fleet requires CGO_ENABLED=1 for certain database drivers (like SQLite)
# and needs the 'include' tags to find the bindata.
RUN CGO_ENABLED=1 go build -o fleet-custom ./cmd/fleet

# STAGE 2: Use the Official Image as the Base
FROM fleetdm/fleet:latest

# Switch to root to perform the swap and fix permissions
USER root

# 1. Move the official binary (which has the assets) to a backup location
# 2. Copy YOUR custom binary into the official path
COPY --from=builder /app/fleet-custom /usr/bin/fleet

# 3. Fix Synology Permissions
# We ensure the binary is executable and matches your Synology UID
RUN chmod +x /usr/bin/fleet && \
    adduser -D -u 1026 syno-louis || true

# Ensure the log directory exists (if you still use it)
RUN mkdir -p /logs && chown -R 1026 /logs

# Switch to your Synology User
USER 1026

ENTRYPOINT ["/usr/bin/fleet"]
CMD ["serve"]
