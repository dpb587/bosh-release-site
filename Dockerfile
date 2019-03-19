FROM alpine:3.4 as binaries
RUN apk --no-cache add wget
RUN mkdir /tmp/binaries
RUN true \
  && wget -qO /tmp/binaries/bosh http://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-3.0.1-linux-amd64 \
  && echo "ccc893bab8b219e9e4a628ed044ebca6c6de9ca0  /tmp/binaries/bosh" | sha1sum -c \
  && chmod +x /tmp/binaries/bosh

FROM golang:1.12
RUN true \
  && wget -qO /usr/local/bin/bosh http://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-3.0.1-linux-amd64 \
  && echo "ccc893bab8b219e9e4a628ed044ebca6c6de9ca0  /usr/local/bin/bosh" | sha1sum -c \
  && chmod +x /usr/local/bin/bosh
RUN true \
  && wget -qO /usr/local/bin/meta4-repo https://github.com/dpb587/metalink/releases/download/v0.3.0/meta4-repo-0.3.0-linux-amd64 \
  && echo "dce06d852585d5a5201b2d21cd864cbdf81dff093747ab368acb8d4fa1e11216  /usr/local/bin/meta4-repo" | sha256sum -c - \
  && chmod +x /usr/local/bin/meta4-repo
RUN true \
  && wget -qO- https://github.com/gohugoio/hugo/releases/download/v0.53/hugo_extended_0.53_Linux-64bit.tar.gz \
    | tar -xzf- -C /usr/local/bin hugo
