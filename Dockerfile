FROM --platform=linux/amd64 golang:1.26.1-trixie@sha256:96b28783b99bcd265fbfe0b36a3ac6462416ce6bf1feac85d4c4ff533cbaa473
LABEL maintainer="Fleet Developers"

RUN apt-get update && apt-get install -y musl-tools && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/fleet
RUN mkdir -p /output

WORKDIR /usr/src/fleet

COPY cmd ./cmd
COPY orbit ./orbit
COPY ee ./ee
COPY server ./server
COPY frontend ./frontend
COPY pkg ./pkg
COPY ./third_party ./third_party
COPY go.mod go.sum ./

# CMD /bin/bash
# 1. Download dependencies
RUN go mod download

# 2. Build the app
RUN go build -o /usr/bin/fleet ./cmd/fleet

# 3. Run the app
EXPOSE 8080
CMD ["fleet", "serve"]
