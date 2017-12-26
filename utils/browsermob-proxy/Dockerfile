FROM qautomatron/docker-browsermob-proxy:2.1.3

RUN apt-get update -qqy \
  && apt-get -qqy install curl

ADD waitProxy.sh /waitProxy.sh
RUN chmod u+x /waitProxy.sh

ENV BMP_PORT 9090
ENV PORT_RANGE 9091-9121

CMD /bin/sh /waitProxy.sh
