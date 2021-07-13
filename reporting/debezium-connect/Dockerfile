FROM debezium/connect:1.5
ENV KAFKA_CONNECT_JDBC_DIR=$KAFKA_CONNECT_PLUGINS_DIR/kafka-connect-jdbc

# Deploy PostgreSQL JDBC Driver
RUN cd /kafka/libs && curl -sO https://jdbc.postgresql.org/download/postgresql-42.2.8.jar

# Deploy Kafka Connect JDBC
RUN mkdir -p $KAFKA_CONNECT_JDBC_DIR && cd $KAFKA_CONNECT_JDBC_DIR &&\
    curl -sO https://packages.confluent.io/maven/io/confluent/kafka-connect-jdbc/10.1.1/kafka-connect-jdbc-10.1.1.jar
