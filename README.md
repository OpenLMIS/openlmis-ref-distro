# openlmis-blue
Temporary location for the OpenLMIS v3+ Reference Distribution

This will hold the future Reference Distribution.  i.e. docker compose files to compose all services together for a OpenLMIS deployment.
This is a work in progress.

## Documentation
Documentation is built using Sphinx. Documents from other OpenLMIS repositories are collected and published on readthedocs.org nightly.

Documentation is available at:
http://openlmis.readthedocs.io

**Blue?**
> Regarding the open-lmis repo, the code name for the repository that will hold the OpenLMIS Reference Distribution is openlmis-blue.
> Why?  Blue as in water, water as it has surface tension, surface tension such as holding things loosely together, loosely held together
> as this is NOT "core"...  Most importantly it's a color and easy to remember, so until we can agree on the new repository name, it's
> openlmis-blue and fierce debate is encouraged.  (most of the previous sentence is meant to convey levity!)
https://openlmis.atlassian.net/wiki/x/SwCwAw

##Running with Service Discovery
To run the complete application, first add an environment file called `.env` to the root folder of the project, with the required 
project settings and credentials. For a starter environment file, you can use [this one](https://github.com/OpenLMIS/openlmis-config/blob/master/.env).

Next, edit the .env file and replace VIRTUAL_HOST and BASE_URL with your machine's IP address. 

Then, run the service with command
> docker-compose up

When the application is up and running, you should be able to access requisition service with
http://<your ip-address>/requisition

## Demo Data
You can use a standard data set for demonstration purposes.
To do so, generate a sql input files using instructions from each microservice (e.g. [this one](https://github.com/OpenLMIS/openlmis-referencedata#demo-data)).
Then for each sql file, with openlmis-blue running, in separate terminal run:
`docker exec -i openlmisblue_db_1 psql -Upostgres open_lmis < input.sql`
