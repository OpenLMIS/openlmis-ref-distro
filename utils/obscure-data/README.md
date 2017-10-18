# Obscure Data

This docker image is a simple utility meant to scrub specific component's data of information
that's more protected:

* passwords
* email addresses
* secret tokens

This is most useful when running a testing instance that's based off of a production data set.

## Configuration

This image is based off of openlmis/run-sql, and so the environment variables needed for that
image are needed here.

This image also needs environment variables which need to be set.  See the [env-sample](env-sample)
to see what needs to be set.

## Example

Lets presume environment variables are defined in:

* refdistro.env - has settings such as
  [these](https://github.com/OpenLMIS/openlmis-config/blob/master/.env).
* obscure.env - has settings such as [these](env-sample).

With those we can obscure a database with:

```
docker run -it --rm --env-file refdistro.env --env-file obscure.env openlmis/obscure-data
```

Or if the database is running as a container in the ref-distro:

```
docker run -it --rm --env-file refdistro.env --env-file obscure.env --network openlmisrefdistro_default openlmis/obscure-data
```
