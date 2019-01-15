# Stop EC2 instance

This utility docker image is intended to help stop EC2 instance.

For this to be useful you need:

* An existing EC2 instance that you want to stop.

## Usage

This image needs a number of environment variables to be set. Since this image is based off of
openlmis/awscli, you may set these environment variables in one or more files. This example will
use two.

### Environment Variables for AWSCLI

To set your AWS credentials and your default region.  See the
[env-sample](https://github.com/OpenLMIS/openlmis-ref-distro/blob/master/utils/awscli/env-sample)
from there.  For our purposes we'll name it `aws.env`.

```
curl -L https://raw.githubusercontent.com/OpenLMIS/openlmis-ref-distro/master/utils/awscli/env-sample > aws.env
```

### Environment Variables for Stop EC2 Instance

This image adds the following additional enviornment variables:

* TARGET_INSTANCE_ID - the id of the EC2 instance to be stopped

A [sample env file](env-sample) is included in this repo.

## example

Presuming we have env files:

* aws.env - has environment variables for awscli.
* stop.env - has environment variables for this image.

Then we could run:

```
docker run -it --rm --env-file aws.env --env-file stop.env openlmis/stop-instance
```
