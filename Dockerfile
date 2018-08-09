FROM golang:alpine as build
MAINTAINER kenneth@floss.cat
# Based on former Docker: vincit/logspout-gelf
RUN mkdir -p /go/src
WORKDIR /go/src
VOLUME /mnt/routes
EXPOSE 80
RUN apk --no-cache add curl git gcc musl-dev && \
    mkdir -p /go/src/github.com/gliderlabs/ && \
    cd /go/src/github.com/gliderlabs/ && \
    git clone https://github.com/gliderlabs/logspout

WORKDIR /go/src/github.com/gliderlabs/logspout
RUN echo 'import ( _ "github.com/micahhausler/logspout-gelf" )' >> /go/src/github.com/gliderlabs/logspout/modules.go
RUN go get -d -v ./...
RUN go build -v -ldflags "-X main.Version=$(cat VERSION)" -o ./bin/logspout

FROM alpine:latest
COPY --from=build /go/src/github.com/gliderlabs/logspout/bin/logspout /go/bin/logspout
ENTRYPOINT ["/go/bin/logspout"]
