# AWS CLI utility docker image

Wraps the AWS CLI utility - like many other images do.  This has the advantage of being based
off of the openlmis/dev image (so it's overall larger, however it shares layers with openlmis/dev
reducing the actual layers downloaded - hopefully).  When/if AWS produces an official CLI image,
this should likely be replaced.

## Usage

1. This repository comes with a sample environment file.  This sample is meant to be copied, filled
  in with your AWS information, and named something appropriate.  You'll pass this file to the
  docker image so that the AWS CLI may connect to your account.
  ```
  curl -L https://raw.githubusercontent.com/OpenLMIS/openlmis-ref-distro/master/utils/awscli/env-sample > your.env
  ```

1. You may run interactively with:
  ```
  docker run -it --rm --env-file your.env openlmis/awscli
  > aws rds describe-db-instances
  ```

1. Alternatively, the image has bash and you can run a script like so:
  ```
  echo "aws rds describe-db-instances" > runme.sh
  docker run -it --rm --env-file your.env -v $(pwd)/runme.sh:/app/runme.sh openlmis/awscli /bin/sh runme.sh
  ```
