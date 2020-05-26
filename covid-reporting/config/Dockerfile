FROM gliderlabs/alpine:3.4

COPY ./services /config

RUN apk update && apk upgrade && \
    apk add curl && \
    apk add bash && \
    apk add bash-completion && \
    rm -rf /var/cache/apk/*

ENTRYPOINT [""]
CMD /bin/true
