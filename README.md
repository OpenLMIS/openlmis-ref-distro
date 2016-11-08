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

* docker compose on Windows hasn't supported our development environment setup, so you _can_ use Docker for Windows to run Blue, but not to develop
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

2. Pull all the services, and bring the reference distribution up.  Since this is actively developed, you __should pull the services frequently__.
  ```
  $ docker-compose pull
  $ docker-compose up -d  # drop the -d here to see console messages
  ```

3. When the application is up and running, you should be able to access the Reference Distribution at:

	```
	http://<your ip-address>/public
	```

	_note if_ you get a `HTTP 502: Bad Gateway`, that's probably okay.  Just wait a few minutes as not everything has started yet.
  
  With a fresh installation, you can log in with the username 'admin' and password 'password'. The demo data (below) also provides
  a username 'administrator' with the same password. These are initial accounts that should be immediately used to create a specific
  new administrator login and then deactivated. See the Configuration Guide for more about the OpenLMIS setup process.

4. To stop the application & cleanup:

	* if you ran `docker-compose up -d`, stop the application with `docker-compose down -v`
	* if you ran `docker-compose up` _note_ the absence of `-d`, then interupt the application with `Ctrl-C`, and perform cleanup by removing containers.  See
	our [docker cheat sheet](https://openlmis.atlassian.net/wiki/x/PwBIAw) for help on manually removing containers.

## Demo Data
You can use a standard data set for demonstration purposes. Each service that has demo data, has 
it stored in its Docker image. The docker-compose.yml file is configured to automatically load the 
demo data through a setting in the JAVA_OPTS environment variable. If you wish to not load demo 
data, or load custom data, you can modify this setting.

In the docker-compose.yml file for each service, look for a line like:
  ```
  JAVA_OPTS: '-Dlogging.config=/logback.xml -Dspring.jpa.properties.hibernate.hbm2ddl.import_files=/bootstrap.sql,file:///demo-data/data.sql'
  ```

If you wish to not load demo data, you can remove the demo data load entry:
  ```
  JAVA_OPTS: '-Dlogging.config=/logback.xml -Dspring.jpa.properties.hibernate.hbm2ddl.import_files=/bootstrap.sql'
  ```

Or, you can replace it with your own by mounting a volume into the Docker container when it starts 
and replacing the demo data entry. Be sure to prefix it with `file://`; otherwise, the service 
will look in the classpath for the file.

*NOTE:* be careful not to remove the `bootstrap.sql` entry, as that file must be loaded for the 
service to function properly.

## Documentation
Documentation is built using Sphinx. Documents from other OpenLMIS repositories are collected and published on readthedocs.org nightly.

Documentation is available at:
http://openlmis.readthedocs.io
