FROM alpine

RUN apk update && apk add bash e2fsprogs sfdisk wget

ADD build.sh /root/

WORKDIR /root

ENTRYPOINT ./build.sh /outdir
