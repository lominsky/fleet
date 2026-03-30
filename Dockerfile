FROM --platform=linux/amd64 golang:1.26-bookworm
ENV GOTOOLCHAIN=auto
LABEL maintainer="Fleet Developers"

RUN apt-get update && apt-get install -y musl-tools && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/src/fleet
RUN mkdir -p /output

WORKDIR /usr/src/fleet

COPY orbit ./orbit
COPY server ./server
COPY ee ./ee
COPY pkg ./pkg
COPY ./third_party ./third_party
COPY go.mod go.sum ./

# This creates the executable and places it in /usr/bin/fleet
RUN go build -o /usr/bin/fleet ./cmd/fleet

# Set permissions to make it executable
RUN chmod +x /usr/bin/fleet

CMD /bin/bash
