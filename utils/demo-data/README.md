# Demo Data

This docker image contains demo data and a script to load that data.

## Configuration

This image is based off of openlmis/run-sql, and so the environment variables needed for that
image are needed here.

## Example

Lets presume environment variables are defined in:

* settings.env - has settings such as
  [these](https://github.com/OpenLMIS/openlmis-ref-distro/blob/master/settings-sample.env).

With those we can load demo into a database with:

```
docker run -it --rm --env-file settings.env openlmis/demo-data
```

Or if the database is running as a container in the ref-distro:

```
docker run -it --rm --env-file settings.env --network openlmis-ref-distro_default openlmis/demo-data
```
