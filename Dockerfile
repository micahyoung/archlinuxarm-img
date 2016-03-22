FROM alpine

RUN apk update && apk add bash e2fsprogs sfdisk curl ca-certificates

ADD build.sh /root/

WORKDIR /root

ENTRYPOINT ./build.sh /outdir
