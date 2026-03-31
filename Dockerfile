# --- STAGE 1: Build Frontend ---
FROM node:18-slim AS frontend-builder
WORKDIR /usr/src/fleet
COPY frontend/ ./frontend/
# Fleet's frontend build usually lives in the frontend directory
RUN cd frontend && npm install && npm run build

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
