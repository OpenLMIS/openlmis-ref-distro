# OpenLMIS Reference Distribution
Location for the OpenLMIS v3+ Reference Distribution

The Reference Distribution utilizes Docker Compose to gather the published OpenLMIS Docker Images together and
launch a running application.  These official OpenLMIS images are updated frequently and published to 
[our](https://hub.docker.com/u/openlmis/) Docker Hub. These images cover all aspects of OpenLMIS: from server-side
Services and infrastructure to the reference UI modules that a client's browser will consume.

The docker-compose files within this repository should be considered the authoritative OpenLMIS Reference Distribution,
as well as a template for how OpenLMIS' services and UI modules should be put together in a deployed instance of
OpenLMIS following our architecture.

## Starting the Reference Distribution

## Tech Requirements

* Docker Engine: 1.12+
* Docker Compose: 1.8+

Note that Docker on Mac and Windows hasn't always been as native as it is now with [Docker for Mac](https://www.docker.com/products/docker#/mac) 
and [Docker for Windows](https://www.docker.com/products/docker#/windows).  If you're using one of these, please note that there are some known issues:

* docker compose on Windows hasn't supported our development environment setup, so you _can_ use Docker for Windows to run the Reference Distribution, but not to develop
* if you're on a Virtual Machine, finding your correct IP may have some caveats - esp for development


### Quick Setup

1. Pull the environment file template, edit `VIRTUAL_HOST` and `BASE_URL` to be your IP address (if you're behind a NAT, then don't mistakenly use the router's address),
You __should only need to do this once__, though as this is an actively developed application, you may need to check the environment file template for new additions.
  ```
  $ curl -LO https://raw.githubusercontent.com/OpenLMIS/openlmis-config/master/.env
  ```

  Note that 'localhost' will not work here—-it must be an actual IP address (like aaa.bbb.yyy.zzz). This is because localhost would be interpreted
  relative to each container, but providing your workstation's IP address gives an absolute outside location that is reachable from each container.
  Also note that your BASE_URL will not need the port ":8080" that may be in the environment file template.

2. Pull all the services, and bring the Reference Distribution up.  Since this is actively developed, you __should pull the services frequently__.
  ```
  $ docker-compose pull
  $ docker-compose up -d  # drop the -d here to see console messages
  ```

3. When the application is up and running, you should be able to access the Reference Distribution at:

	```
	http://<your ip-address>/
	```

	_note if_ you get a `HTTP 502: Bad Gateway`, that's probably okay.  Just wait a few minutes as not everything has started yet.
  
  By default the demo configuration (facilities, geographies, users, etc) is loaded on startup. To use that demo you may start 
  with a demo account:
  
  ```
  Username:  administrator
  Password: password
  ```
  
  If you opted not to load the demo data, and instead need a bare-bones account to configure your system, de-activate the 
  demo data and use the bootstrap account:
  
  ```
  Username: admin
  Password: password
  ```
  
  If you are configuring a production instance, be sure to secure these accounts ASAP and refer to the Configuration Guide 
  for more about the OpenLMIS setup process.

4. To stop the application & cleanup:

	* if you ran `docker-compose up -d`, stop the application with `docker-compose down -v`
	* if you ran `docker-compose up` _note_ the absence of `-d`, then interupt the application with `Ctrl-C`, and perform cleanup by removing containers.  See
	our [docker cheat sheet](https://openlmis.atlassian.net/wiki/x/PwBIAw) for help on manually removing containers.

## Demo Data
You can use a standard data set for demonstration purposes. Each service that has demo data, has
it stored in its Docker image. The demo data is built from JSON sources in each service's repo:
* [Auth Service Demo Data](https://github.com/OpenLMIS/openlmis-auth/tree/master/demo-data)
* [Reference Data Demo Data](https://github.com/OpenLMIS/openlmis-referencedata/tree/master/demo-data)
* [Requisition Demo Data](https://github.com/OpenLMIS/openlmis-requisition/tree/master/demo-data)
* [Fulfillment Demo Data](https://github.com/OpenLMIS/openlmis-fulfillment/tree/master/demo-data)

The docker-compose.yml file is configured to automatically load the demo data through a setting in
the JAVA_OPTS environment variable. If you wish to not load demo data, or load custom data, you can
modify this setting.

In the docker-compose.yml file, look for a line like the following for each service with demo data:
  ```
  JAVA_OPTS: '-Dlogging.config=/logback/logback.xml -Dspring.jpa.properties.hibernate.hbm2ddl.import_files=/bootstrap.sql,file:///demo-data/data.sql'
  ```

If you wish to not load demo data, you can remove the demo data load entry:
  ```
  JAVA_OPTS: '-Dlogging.config=/logback/logback.xml -Dspring.jpa.properties.hibernate.hbm2ddl.import_files=/bootstrap.sql'
  ```

Or, you can replace it with your own by mounting a volume into the Docker container when it starts 
and replacing the demo data entry. Be sure to prefix it with `file://`; otherwise, the service 
will look in the classpath for the file.

*NOTE:* be careful not to remove the `bootstrap.sql` entry, as that file must be loaded for the 
service to function properly.

## Configuring Services

When a container needs configuration via a file (as opposed to an environment variable for example), then
there is a special Docker image that's built as part of this Reference Distribution from the Dockerfile of 
the `config/` directory.  This image, which will also be deployed as a container, is only a vessel for 
providing a named volume from which each container may mount the `/config` directory in order to self-configure.

To add configuration:

1. Create a new directory under `config/`.  Use a unique and clear name. e.g. *kannel*.
2. Add the configuration files in this directory.  e.g. `config/kannel/kannel.config`.
3. Add a COPY statement to `config/Dockerfile` which copies the configuration file to the container's `/config`.
e.g. `COPY kannel/kannel.config /config/kanel/kannel.config`.
4. Ensure that the container which will use this configuration file mounts the named-volume `service-config` to
`/config.  e.g.
  
  ```shell
  kannel:
    image: ...
    volumes:
      - 'service-config:/config'
  ```
5. Ensure the container uses/copies the configuration file from `/config/...`.
6. When you add new configuration, or change it, ensure you bring this Reference Distribution with the `--build`
flag.  e.g. `docker-compose up --build`.

The logging configuration utilizes this method.

_NOTE:_ that the configuration container that's built here doesn't _run_.  It is normal for it's Status to be 
Exited.

## Logging

Logging configuration is "passed" to each service as a file (logback.config) through a named docker volume:
`service-config`.  To change the logging configuration:

1. update `config/log/logback.xml`
2. bring the application up with `docker-compose up --build`.  The `--build` option will re-build the
configuration image.

Most logging is collected by way of rsyslog (in the `log` container) which writes to the named volume: `log`.
However not every docker container logs via rsyslog to this named volume.  For these services they log either
via docker logging or to a file for which a named-volume approach works well.

### Log container

The `log` container runs rsyslog which Services running in their own containers may forward their logging
messages to.  This helps centralize all the various Service logging into one location.  This container writes
all of these messages to the file `/var/log/messages` of the named volume `syslog`.

To read this file, you may mount this filesystem via:

```shell
$ docker run -it --rm -v openlmisrefdistro_syslog:/var/log openlmis/dev:1 bash
> tail /var/log/messages
```

#### Log format for Services

The default log format for the Services is below:

* `<timestamp> <container ID> <thread ID> <log level> <logger / Java class> <log message>`

The format from the thread ID onwards can be changed in the `config/log/logback.xml` file.

### Nginx container

The `nginx` container runs the nginx and consul-template processes.  These two log to the named volumes:

* `nginx-log` under `/var/log/nginx/log`
* `consul-template-log` under `/var/log/consul/template`

e.g to see Nginx's access log:

```shell
$ docker run -it --rm -v openlmisrefdistro_nginx-log:/var/log/nginx/log openlmis/dev:1 bash
> tail /var/log/nginx/log/access.log
```

With Nginx it's also possible to use Docker's logging so that both logs are accessible via `docker logs <nginx>`.  
This is owed to the configuration of the official Nginx image.  To use this configuration, change the environment
variable `NGINX_LOG_DIR` to `NGINX_LOG_DIR=/var/log/nginx`.

### Postgres container

If using the postgres container, the logging is accessible via:  `docker logs openlmisrefdistro_db_1`.

## Cleaning the Database

Sometimes it's useful to drop the database completely, for this there is a script included that 
is able to do just that.

*Note this should never be used in production, nor should it ever be deployed*

To run this script, you'll first need the name of the Docker network that the database is using. 
If you're using this repository, it's usually the name `openlmisrefdistro_default`.  With this run 
the command:
 
 ```shell
 docker run -it --rm --env-file=.env --network=openlmisrefdistro_default -v $(pwd)/cleanDb.sh:/cleanDb.sh openlmis/dev:1 /cleanDb.sh
 ```
 Replace `openlmisrefdistro_default` with the proper network name if yours has changed.
 
 *Note that using this script against a remote Docker host is possible, though not advised*
 
## Production

When deploying the Reference Distribution as a production instance, you'll need to remember to set the following 
environment variable so the production database isn't first wiped when starting:

```
export spring_profiles_active="production"
docker-compose up --build -d
```

## Documentation
Documentation is built using Sphinx. Documents from other OpenLMIS repositories are collected and published on readthedocs.org nightly.

Documentation is available at:
http://openlmis.readthedocs.io