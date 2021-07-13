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

1. Copy and configure your settings, edit `VIRTUAL_HOST` and `BASE_URL` to be your IP address
(if you're behind a NAT, then don't mistakenly use the router's address), You __should only need
to do this once__, though as this is an actively developed application, you may need to check the
environment file template for new additions.
  ```
  $ cp settings-sample.env settings.env
  ```

  Note that 'localhost' will not work here—-it must be an actual IP address (like aaa.bbb.yyy.zzz) or domain name.
  This is because localhost would be interpreted relative to each container, but providing your
  workstation's IP address or domain name gives an absolute outside location that is reachable from each container.
  Also note that your BASE_URL will not need the port ":8080" that may be in the environment file
  template.

2. Update api access configs in https://github.com/OpenLMIS/openlmis-ref-distro/blob/master/reporting/.env

3. Pull all the services, and bring the Reference Distribution up.  Since this is actively
developed, you __should pull the services frequently__.
  ```
  $ docker-compose pull
  $ docker-compose up -d  # drop the -d here to see console messages
  ```

4. When the application is up and running, you should be able to access the Reference Distribution at:

	```
	http://<your ip-address>/
	```

	_note if_ you get a `HTTP 502: Bad Gateway`, it is probably still starting up all of the
	microservice containers.  You can wait a few minutes for everything to start.  You can also
	run `docker stats` to watch each container using CPU and memory while starting.

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

5. To stop the application & cleanup:

	* if you ran `docker-compose up -d`, stop the application with `docker-compose down -v`
	* if you ran `docker-compose up` _note_ the absence of `-d`, then interupt the application with `Ctrl-C`, and perform cleanup by removing containers.  See
	our [docker cheat sheet](https://openlmis.atlassian.net/wiki/x/PwBIAw) for help on manually removing containers.
	
6. To enable unskipping previously skipped requisition line items during approval add this flag in settings.env file
   
   ```
   UNSKIP_REQUISITION_ITEM_WHEN_APPROVING=true
   
   ```

## Demo Data

It's possible to load demo data using an environment variable. This variable is
called `spring.profiles.active`.  When this environment has as one of it's 
values `demo-data`, then the demo data for the service will be loaded.  This 
variable may be set in the settings.env file or in your shell with:

```shell
$ export spring_profiles_active=demo-data
$ docker-compose up -d
```

## Performance data

Performance data may also be optionally loaded and is defined by some Services. If you'd like to 
start a demo system with a lot of data, run this script instead of executing step #2 of the Quick 
Setup.

```shell
$ export spring_profiles_active=demo-data
$ ./demo-data-start.sh
```

See http://docs.openlmis.org/en/latest/conventions/performanceData.html for
more.

## Refresh Database (Profile)

This deployment profile is used by a few services to help ensure that the database they're working against is
in a good state.  This profile should be set when:

* Manual updates to the database have been made (INSERT, UPDATE, DELETE) through SQL or another tool other
than the HTTP REST API each service exposes.
* When the Release Notes call for it to be run in an upgrade.

Using this profile means that extra checks and updates are performed.  This uses extra resources such as
memory, cpu, etc.  When set, Services will start slower, sometimes significantly slower.

Usually this profile only needs to be set before the service(s) starts once.  If no further upgrades or manual
database changes are made, the profile may be removed before subsequent starting of the service(s) to quicken
startup time.

```
spring_profiles_active=refresh-db
```

## Docker Compose configuration

The docker-compose.yml file may be customized to change:

* Versions of Services that should be deployed.
* Host ports that should be used for specific Services.

This may be configured in the included [.env](.env) file or overridden by setting the same variable in the shell.

For example to set the HTTP port to 8080 instead of the default 80:

```
export OL_HTTP_PORT=8080
./start-local.sh
```

A couple conventions:

1. The .env file has service versions.  See the [.env](.env) file for more.
1. Port mappings have defaults in the [docker-compose.yml](docker-compose.yml):
  * OL_HTTP_PORT - Host port that the application will be made available.
  * OL_FTP_PORT_20 - Host port that the included FTP's port 20 is mapped to.
  * OL_FTP_PORT_21 - Host port that the included FTP's port 21 is mapped to.


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
`/config`.  e.g.

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

### Log container. How-to log methods in services when working with Ref-Distro - step-by-step

The `log` container runs rsyslog which Services running in their own containers may forward their logging
messages to.  This helps centralize all the various Service logging into one location.  This container writes
all of these messages to the file `/var/log/messages` of the named volume `syslog`.

The steps below work for default settings so you don't have to edit any logback.xml files.

1. Log methods in a service with "DEBUG" level
2. Build the code with `sudo docker-compose run --service-ports <service-name>` followed by `gradle clean build integrationTest`
2. Build an image of the service you're working on with `docker-compose -f docker-compose.builder.yml build image`
3. Change the service's version to the recently built one in .env file, for example: `OL_REFERENCEDATA_VERSION=latest`
4. Bring the application up with `docker-compose -f docker-compose.yml up`
5. Check what is the version of your openlmis/dev image 
6. To read the file with logs, mount this filesystem via:
```shell
docker run -it --rm -v openlmis-ref-distro_syslog:/var/log openlmis/dev:<your-image-version> bash
> tail /var/log/messages
```
Different versions of docker and different deployment configurations can result in different names of the syslog volume. If `openlmis-ref-distro_syslog` doesn't work, run `docker volume ls` to see all volume names.

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
$ docker run -it --rm -v openlmis-ref-distro_nginx-log:/var/log/nginx/log openlmis/dev:3 bash
> tail /var/log/nginx/log/access.log
```

Different versions of docker and different deployment configurations can result in different names of the syslog volume. If `openlmis-ref-distro_nginx-log` doesn't work, run `docker volume ls` to see all volume names.

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
 docker run -it --rm --env-file=.env --network=openlmisrefdistro_default -v $(pwd)/cleanDb.sh:/cleanDb.sh openlmis/dev:3 /cleanDb.sh
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
