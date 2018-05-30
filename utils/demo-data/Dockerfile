FROM openlmis/run-sql

COPY load.sh /load.sh
RUN chmod u+x /load.sh
COPY wait-for-postgres.sh /wait-for-postgres.sh
RUN chmod u+x /wait-for-postgres.sh
COPY data /data

CMD /load.sh