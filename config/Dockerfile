FROM alpine:3.21

WORKDIR /stage

COPY log/ ./log/
COPY reports/ ./reports/

RUN chmod -R 644 ./log
RUN chmod -R 644 ./reports

CMD ["sh", "-c", "cp -a /stage/. /config/"]
