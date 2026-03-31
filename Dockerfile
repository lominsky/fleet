# --- STAGE 1: Build Frontend ---
FROM node:18-slim AS frontend-builder
# Set Node options to limit heap memory
ENV NODE_OPTIONS="--max-old-space-size=1536"
WORKDIR /usr/src/fleet
COPY frontend/ ./frontend/
# Use 'npm ci' instead of 'install' for faster, more stable builds
RUN cd frontend && npm ci && npm run build

# --- STAGE 2: Build Go Binary ---
FROM golang:1.23-bookworm
RUN apt-get update && apt-get install -y musl-tools git && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/fleet

# Copy everything from your repo
COPY . .

# Copy the compiled assets from STAGE 1 into the Go source tree
COPY --from=frontend-builder /usr/src/fleet/frontend/dist ./server/bindata/

# Build the Go binary using the bindata tag
RUN go build -o /usr/bin/fleet -tags "bindata" ./cmd/fleet

# --- STAGE 3: Final Execution ---
EXPOSE 8080

# This is the magic command that sets up your DB and starts the app
CMD ["sh", "-c", "/usr/bin/fleet prepare db --no-prompt && /usr/bin/fleet serve"]
