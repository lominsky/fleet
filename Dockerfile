# STAGE 1: Build the React Frontend
FROM node:20-alpine AS frontend-builder
RUN apk add --no-cache make g++ python3 git libtool autoconf automake nasm
WORKDIR /app
COPY . .

# 1. Install dependencies
RUN npm install --legacy-peer-deps

# 2. Increase Node memory limit and run the build
# We use 'npx' to ensure it uses the local gulp/webpack version
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npx gulp default || npm run build

# STAGE 2: Build the Go Backend
FROM golang:1.26-alpine AS backend-builder
RUN apk add --no-cache make git
WORKDIR /app
COPY . .
# Copy the built assets from Stage 1
COPY --from=frontend-builder /app/assets ./assets
# Install go-bindata and bundle the assets into the Go source
RUN go install github.com/kevinburke/go-bindata/go-bindata@latest
RUN /go/bin/go-bindata -o server/bindata/bindata.go -pkg bindata assets/...
# Build your custom binary
RUN go build -o fleet ./cmd/fleet

# STAGE 3: Final Production Image
FROM alpine:latest
RUN apk add --no-cache ca-certificates
# Match your Synology user ID
RUN adduser -D -u 1026 fleet
WORKDIR /home/fleet
COPY --from=backend-builder /app/fleet /usr/bin/fleet
# Ensure it can write to logs if you still use them
RUN mkdir -p /logs && chown -R 1026 /logs
USER 1026
ENTRYPOINT ["/usr/bin/fleet"]
CMD ["serve"]
