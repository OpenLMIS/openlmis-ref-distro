FROM alpine:3.21

WORKDIR /stage

COPY log/ ./log/

RUN chmod -R 644 ./log

CMD ["sh", "-c", "cp -a /stage/. /config/"]
