FROM golang:1.23-bookworm
LABEL maintainer="Fleet Developers"

# 1. Install build dependencies
RUN apt-get update && apt-get install -y musl-tools git nodejs npm && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/fleet

# 2. Copy source code
COPY . .

# 3. Build the Frontend (Crucial to prevent the 'Assets' panic)
# Fleet requires the frontend to be compiled into Go files first
RUN cd frontend && npm install && npm run build
RUN go install github.com/kevinburke/go-bindata/go-bindata@latest
RUN go generate ./server/bindata/...

# 4. Download Go dependencies
RUN go mod download

# 5. Build the app with the bindata tag
RUN go build -o /usr/bin/fleet -tags "bindata" ./cmd/fleet

# 6. Set up the entrypoint
# This prepares the DB and then starts the server
# EXPOSE 8080
CMD ["sh", "-c", "/usr/bin/fleet prepare db --no-prompt && /usr/bin/fleet serve"]
