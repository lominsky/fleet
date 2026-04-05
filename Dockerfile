# STAGE 1: Extract the "Good" Assets
# We use the official image as a "parts bin"
FROM fleetdm/fleet:latest AS official-fleet

# STAGE 2: Build YOUR Custom Backend
FROM golang:1.23-alpine AS builder

# 1. Install Go build tools
RUN apk add --no-cache make git

WORKDIR /app
COPY . .

# 2. THE SECRET SAUCE: 
# Replace your local 'placeholder.go' with the actual compiled UI assets 
# from the official image. This stops the "Assets may not be used..." panic.
COPY --from=official-fleet /app/server/bindata/bindata.go ./server/bindata/bindata.go

# 3. Build YOUR custom binary
# The compiler will now see the real UI assets instead of the placeholder
RUN go build -o fleet ./cmd/fleet

# STAGE 3: Final Production Image
FROM alpine:latest
RUN apk add --no-cache ca-certificates

# Match your Synology UID (1026) to avoid permission errors
RUN adduser -D -u 1026 fleet
WORKDIR /home/fleet

COPY --from=builder /app/fleet /usr/bin/fleet
RUN chmod +x /usr/bin/fleet

# Ensure logging directory exists for the container
RUN mkdir -p /logs && chown -R 1026 /logs

USER 1026
ENTRYPOINT ["/usr/bin/fleet"]
CMD ["serve"]
