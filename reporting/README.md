# OpenLMIS Reporting Stack

## Deploying to a Server
1. *Prerequisite:* You should first [deploy OpenLMIS](../README.md). OpenLMIS and the reporting stack must run on separate (virtual) machines. Your OpenLMIS instance should have HTTPS enabled to connect to the reporting stack.

2. *Prerequisite:* You should have a server with two domain names pointing to it, one for Superset and one for NiFi (e.g. `nifi.foo.openlmis.org` and `superset.foo.openlmis.org`). Ports 80 and 443 should be open on the server.

3. Configure OpenLMIS to authenticate with the reporting stack's components. If your OpenLMIS instance is using the `demo-data` spring profile, this is already setup.
  You need two users in OpenLMIS: one for Superset and one for NiFi. The instructions below describe how to set up these users ("OAuth User for Superset" and "OpenLMIS user with all permissions for Superset").

4. From this directory (`openlmis-ref-distro/reporting/`) on the server, copy and configure your settings.
  ```
  $ cp settings-sample.env settings.env
  ```
  * Edit `settings.env` to match your setup. You will likely need to change `VIRTUAL_HOST`, `TRUSTED_HOSTNAME`, and `OL_BASE_URL` (to point to OpenLMIS) and `NIFI_DOMAIN_NAME` and `SUPERSET_DOMAIN_NAME` (which should point to the reporting stack).
  Details on all the environment variables are below.

5. Bring up the reporting stack by running [docker-compose](https://docs.docker.com/compose/) on the server:
  ```sh
  docker-compose up --build -d
  ```
  * You might, at times, want to take down the stack including all the created volumes. We recommend you do this if you ever change configurations in either the [./db](./db) or [./config](./config) directories:

  ```sh
  docker-compose down -v
  ```

6. The Superset webapp should now be running on your server. From your local browser, navigate to your Superset domain. You should be presented with a sign-in screen:
  <img src="./superset-login.png" alt="Superset sign-in screen, with the first provider button outlined in red" width="300px"/>

7. Click the arrow (outlined in red above) to select OpenLMIS OAuth provider. Then, click the "Sign In" button. Enter the credentials for your OpenLMIS user for Superset. On the next page, approve all the requested permissions. Now, when you navigate to the Superset domain, a dashboard should populate with data from your OpenLMIS instance.

8.  If you have an OpenLMIS user with the proper permissions, you can also log in to OpenLMIS and navigate to `https://<OpenLMIS Domain>/#!/reports/list` and then select a report that uses the reporting stack (e.g. stockouts) to access Superset from OpenLMIS. This will require authorizing Superset by following the on-screen instructions.

9. You should be able to access NiFi by navigating to the `NIFI_DOMAIN_NAME`, if you set it up.

## OAuth User for Superset

In order to use user authentication in Superset by an OpenLMIS instance we need to create additional user in OpenLMIS.
It is the specific user with `authorizedGrantTypes` set to `authorization_code`

Example of a SQL statement creating that user (superset:changeme):
```
INSERT INTO auth.oauth_client_details (clientId,authorities,authorizedGrantTypes,clientSecret,"scope")
VALUES ('superset','TRUSTED_CLIENT','authorization_code','changeme','read,write');
```

Don't forget to set newly created user's credentials in settings.env. Example:
```
OL_SUPERSET_USER=superset
OL_SUPERSET_PASSWORD=changeme
```

## OpenLMIS user with all permissions for Superset

The ETL process conducted via NiFi requires a user which has all permissions (all program + supervisory node pairs) to read data from all requisitions in the system. It should not be a simple admin, because sometime it doesn't has all permissions (eg. for requisitions)

The simplest way to create that user is using the https://github.com/OpenLMIS/openlmis-refdata-seed tool.

Note: Created user must have an email address.


Don't forget to set newly created user's credentials in settings.env. Example:
```
OL_ADMIN_USERNAME=administrator
OL_ADMIN_PASSWORD=password
```

## Environment variables

The following environment variables have to be set to sucessfuly run the reporting stack. The sample settings file can be found [here](settings-sample.env).

### NginX
* **VIRTUAL_HOST** - The virtual host for the nginx server - nginx will make services available under this host.
* **NGINX_BASIC_AUTH_USER** and **NGINX_BASIC_AUTH_PW** - for services (like NiFi) that need to be authenticated but currently don't, by themselves, authenticate users

### PostgreSQL Database
* **POSTGRES_USER** - The database superadmin's username.
* **POSTGRES_PASSWORD** - The database password that services will use.

### Nifi Service
* **AUTH_SERVER_CLIENT_ID** and **AUTH_SERVER_CLIENT_SECRET** - InvokeHttp components of Nifi needs to be authorized by credentials of OpenLMIS UI
* **TRUSTED_HOSTNAME** - InvokeHttp components of Nifi needs to specify trusted hostname
* **OL_ADMIN_USERNAME** and **OL_ADMIN_PASSWORD** - Nifi needs an OpenLMIS user which has all possible permissions
* **FHIR_ID** and **FHIR_PASSWORD** - FHIR credentials (leave blank if not used)
* **NIFI_DOMAIN_NAME** - The domain name to use for NiFi
* **NIFI_SSL_CERT** - The name of the SSL certificate file in services/nginx/tls to use with the NiFi domain
* **NIFI_SSL_KEY** - The name of the SSL key file in services/nginx/tls to use with the NiFi domain
* **NIFI_SSL_CERT_CHAIN** - The name of the SSL certificate chain file in services/nginx/tls to use with the NiFi domain
* **NIFI_ENABLE_SSL** - Whether to enable accessing the NiFi domain securely
* **NIFI_BEHIND_LOAD_BALANCER** Whether Nifi is behind a load balancer
* **NIFI_LOAD_BALANCER_REDIRECT_HTTP** - Whether to redirect HTTP traffic on the load balancer to https


### Superset Service
* **OL_BASE_URL** - Superset will be configured with OpenLMIS instance under this URL
* **SUPERSET_ADMIN_USERNAME** and **SUPERSET_ADMIN_PASSWORD** - Superset webapp credentials - there is the option to sing-in by them when OAUTH provider is disabled. Because there is currently no way to disable the OAuth provider, the corresponding SUPERSET_ADMIN_USERNAME and PASSWORD values are currently always ignored.
* **SUPERSET_POSTGRES_USER** and **SUPERSET_POSTGRES_PASSWORD** - Superset Postgres credentials
* **OL_SUPERSET_USER** and **OL_SUPERSET_PASSWORD** - Superset needs an OpenLMIS user which allows to sign-in via OAUTH
* **SUPERSET_SECRET_KEY** - Secret key for flask in Superset
* **OAUTHLIB_INSECURE_TRANSPORT** - Disabling SSL check in Superset service. By default sign-in via OAUTH requires OpenLMIS with HTTPS security
* **SUPERSET_DOMAIN_NAME** - The domain name to use for Superset
* **SUPERSET_SSL_CERT** - The name of the SSL certificate file in services/nginx/tls to use with the Superset domain
* **SUPERSET_SSL_KEY** - The name of the SSL key file in services/nginx/tls to use with the Superset domain
* **SUPERSET_SSL_CERT_CHAIN** - The name of the SSL certificate chain file in services/nginx/tls to use with the Superset domain
* **SUPERSET_ENABLE_SSL** - Whether to enable accessing the Superset domain securely
* **SUPERSET_BEHIND_LOAD_BALANCER** - Whether Superset is behind a load balancer
* **SUPERSET_LOAD_BALANCER_REDIRECT_HTTP** - Whether to redirect HTTP traffic on the load balancer to https

### Scalyr
* **SCALYR_API_KEY** - API key for scalyr service


## Running Locally

* While it is possible to run the reporting stack locally, it is not entirely supported, and you cannot run both the reporting stack and OpenLMIS locally at the same time.
* It's easiest to access superset and nifi by leaving `.env` alone, and adding
    entries to our host's `/etc/hosts` file:
    ```
    127.0.0.1   nifi.local superset.local
    ```

### Running Setup Without Scalyr

There are some cases (when running on a dev machine, for instance) where you would prefer to spin-up the stack without the Scalyr container running. To do that, run docker-compose this way:

```sh
docker-compose up --build -d --scale scalyr=0
```


## Experimental Features

### Running with Debezium

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


### Notes on running Kafka

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
