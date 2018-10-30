# OpenLMIS Reporting Stack

Bring up the reporting stack by running:

```sh
docker-compose up --build -d
```

You might, at times, want to take down the stack including all the created volumes. We recommend you do this if you ever change configurations in either the [./db](./db) or [./config](./config) directories:

```sh
docker-compose down -v
```

## Running Setup Without Scalyr

There are some cases (when running on a dev machine, for instance) where you would prefer to spin-up the stack without the Scalyr container running. To do that, run docker-compose this way:

```sh
docker-compose up --build -d --scale scalyr=0
```

## Running with Debezium (WIP & Experimental Data Pump)

Debezium is a change data capture platform - it is able to stream changes from
a database, such as Postgres, into Kafka using the Kafka Connect API.

This approach is still very much a proof of concept, and requires:

- You launch OpenLMIS' Ref Distro
- You launch Kafka et al with Debezium's `connect` container with network
    access to the Postgres DB's of the Ref Distro services.

Steps:

1. Start in the root of this repository.
2. `./start-local.sh` to start OpenLMIS Ref Distro.
3. `cd reporting` in a new terminal.
4. `./debezium-start.sh` to start Kafka and Debezium Connect.
5. In a new terminal:  `./debezium-referencedata-start.sh` to start the
    connector.  Note this should be 1 per Postgres cluster.
6. (optional) `./debezium-console.sh` to show the events streamed to the topic.