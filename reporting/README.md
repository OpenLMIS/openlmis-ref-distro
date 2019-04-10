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

## Notes on running locally

* It's easiest to access superset and nifi by leaving `.env` alone, and adding
    entries to our host's `/etc/hosts` file:
    ```
    127.0.0.1   nifi.local superset.local
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


## Notes on running Kafka

First, Kafka is not required for running the reporting stack.  This stack is
a WIP:

1. Kafka was used early on, along with Druid, as part of the DISC indicator work
    for vaccines.
1. Kafka and Druid we're removed from the stack, in place of Nifi implementing
    the entire pipeline delivering into a Postgres data store.
1. Looking forward, we see Kafka re-entering as a central backbone for moving
    data:  From services (streamed using Debezium), to intermediary processors,
    and then sunk (loaded) into the destination database.

When working with Kafka some of these tips are helpful:
* On listeners, ports, and networking: https://rmoff.net/2018/08/02/kafka-listeners-explained/
