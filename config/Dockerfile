FROM gliderlabs/alpine:3.4

COPY log/logback.xml /config/log/logback.xml
COPY wait-for-postgres.sh /config/wait-for-postgres.sh
RUN chmod u+x /config/wait-for-postgres.sh

CMD /bin/true

