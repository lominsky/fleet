# Stage 1: Build the binary
FROM golang:1.26.1-alpine AS builder

# 1. Install EVERYTHING needed for Go + Node.js Native Compilation
RUN apk add --no-cache \
    make \
    git \
    nodejs \
    npm \
    python3 \
    g++ \
    gcc \
    libc-dev \
    linux-headers

WORKDIR /app
COPY . .

# 2. Build the Frontend (The "Assets")
# We run these manually to ensure they complete before the Go build
RUN npm install
RUN npm run build  # Fleet usually maps 'make assets' to this or a gulp task

# 3. Build the Go Binary
# We use the -tags to ensure the assets are properly seen
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
