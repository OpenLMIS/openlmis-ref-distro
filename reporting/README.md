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
