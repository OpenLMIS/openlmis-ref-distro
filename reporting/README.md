## Running Setup Without Scalyr

There are some scenarios (when running on a dev machine, for instance) where you would prefer to spin-up docker-compose without the Scalyr container running. To do that, run docker-compose this way:

```
docker-compose up --scale scalyr=0
```
