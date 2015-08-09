FROM debian:jessie

ENV CONSUL_VERSION 0.5.2
ENV CONSUL_HOME /opt/consul

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  unzip

RUN curl -sLo /tmp/consul.zip https://dl.bintray.com/mitchellh/consul/${CONSUL_VERSION}_linux_amd64.zip \
  && unzip -d /bin /tmp/consul.zip \
  && rm /tmp/consul.zip

ENTRYPOINT ["/bin/consul"]
