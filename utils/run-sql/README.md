# OpenLMIS Run sql

Utility Docker image for running PSQL against a database whose connection
is defined in [OpenLMIS Config](https://github.com/OpenLMIS/openlmis-config/blob/master/.env).

To run:

```
$ cd openlmis-ref-distro
$ docker run -it --rm --env-file .env openlmis/run-sql
/ psql ...
```

To run when postgres is resolved in the .env file by the docker network:

```
$ cd openlmis-ref-distro
$ docker run -it --rm --env-file .env --network openlmisrefdistro_default openlmis/run-sql
/ psql ...
```

To run volume mounted SQL, first create a docker image of the `/sql` folder, and structure
your sql files in that volume to be run from a control sql file like `start.sql`, and then:

```
docker run --rm --env-file .env -v somevol:/sql openlmis/run-sql psql -c /sql/start.sql
```
