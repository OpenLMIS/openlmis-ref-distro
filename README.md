# openlmis-blue
Temporary location for the OpenLMIS v3+ Reference Distribution

The Reference Distribution utilizes Docker Compose to gather the published OpenLMIS Docker Images together and
launch a running application.  These official OpenLMIS images are updated frequently and published to 
[our](https://hub.docker.com/u/openlmis/) Docker Hub. These images cover all aspects of OpenLMIS: from server-side
Services and infrastructure to the reference UI modules that a client's browser will consume.

The docker-compose files within this repository should be considered the authoritative OpenLMIS Reference Distribution,
as well as a template for how OpenLMIS' services and UI modules should be put together in a deployed instance of
OpenLMIS following our architecture.

**Blue?**
> Regarding the open-lmis repo, the code name for the repository that will hold the OpenLMIS Reference Distribution is openlmis-blue.
> Why?  Blue as in water, water as it has surface tension, surface tension such as holding things loosely together, loosely held together
> as this is NOT "core"...  Most importantly it's a color and easy to remember, so until we can agree on the new repository name, it's
> openlmis-blue and fierce debate is encouraged.  (most of the previous sentence is meant to convey levity!)
https://openlmis.atlassian.net/wiki/x/SwCwAw

## Starting the Reference Distribution

## Tech Requirements

* Docker Engine: 1.12+
* Docker Compose: 1.8+

Note that Docker on Mac and Windows hasn't always been as native as it is now with [Docker for Mac](https://www.docker.com/products/docker#/mac) 
and [Docker for Windows](https://www.docker.com/products/docker#/windows).  If you're using one of these, please note that there are some known issues:

* docker compose on Windows hasn't supported our development environment setup
* if you're on a Virtual Machine, finding your correct IP may have some caveats - esp for development


### Quick Setup

1. Pull the environment file template, edit `VIRTUAL_HOST` and `BASE_URL` to be your IP address (if you're behind a NAT, then don't mistakenly use the router's address),
You __should only need to do this once__, though as this is an actively developed application, you may need to check the environment file template for new additions.
  ```
  $ curl -LO https://raw.githubusercontent.com/OpenLMIS/openlmis-config/master/.env
  ```

2. Pull all the services, and bring the reference distribution up.  Since this is actively developed, you __should pull the services frequently__.
  ```
  $ docker-compose pull
  $ docker-compose up
  ```

When the application is up and running, you should be able to access the Reference Distribution at:

```
http://<your ip-address>/
```

Since this is under active development, note that the above may give you a 404.  This is okay, some reachable endpoints:

* `http://<your ip-address>/requisition`
* `http://<your ip-address>/auth`
* `http://<your ip-address>/referencedata`

## Demo Data
You can use a standard data set for demonstration purposes.
To do so, generate a sql input files using instructions from each microservice (e.g. [this one](https://github.com/OpenLMIS/openlmis-referencedata#demo-data)).
Then for each sql file, with openlmis-blue running, in separate terminal run:
`docker exec -i openlmisblue_db_1 psql -Upostgres open_lmis < input.sql`

## Documentation
Documentation is built using Sphinx. Documents from other OpenLMIS repositories are collected and published on readthedocs.org nightly.

Documentation is available at:
http://openlmis.readthedocs.io
