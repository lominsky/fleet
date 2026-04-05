# Stage 1: Build the binary
FROM golang:1.26.1-alpine AS builder

# Install the "Build Essential" equivalents for Alpine
RUN apk add --no-cache \
    make git nodejs npm python3 g++ gcc libc-dev linux-headers \
    libtool automake autoconf nasm

WORKDIR /app
COPY . .

# 1. Fleet's frontend often requires --legacy-peer-deps to handle 
# version conflicts in its React components.
RUN npm install --legacy-peer-deps

# 2. Generate the assets. Note: Fleet usually uses 'make assets' 
# which calls a specialized internal tool.
RUN make assets

# 3. Build the Go binary
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
