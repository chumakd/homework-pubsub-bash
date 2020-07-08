# builder image
FROM golang:alpine as builder

RUN apk add --no-cache git
RUN git clone https://github.com/msoap/shell2http.git $GOPATH/src/github.com/msoap/shell2http

WORKDIR $GOPATH/src/github.com/msoap/shell2http
ENV CGO_ENABLED=0
RUN go install -a -v -ldflags="-w -s" ./...

# final image
FROM debian

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install \
       inotify-tools \
       tree

COPY --from=builder /go/bin/shell2http /usr/local/bin/
COPY pubsub-lib.sh /usr/local/bin/
COPY pubsubd /usr/local/bin/

EXPOSE 3000

ENTRYPOINT ["shell2http", "-port", "3000", "-cgi", "/"]
CMD ["pubsubd"]
