# Restore RDS Snapshot

This utility docker image is intended to help restore an RDS instance from a _named_ snapshot.

**Production Caution**:  This image has not been tested in production and so caution should be used
if using this as part of a production deployment.  It's best for testing and staging environments.

For this to be useful you need:

* An existing RDS instance that you want to replace (overwrite).
* A snapshot which you want to replace the aforementioned RDS instance with.

This is a basic utility image which is unlikely to work with more complex RDS configurations, a
non-exhaustive list might be:

* Multi-AZ deployments
* Clusters
* Complex VPC configurations
* SSL
* ... and certainly many more...

## Usage

This image needs a number of environment variables to be set.  Since this image is based off of
openlmis/awscli, you may set these environment variables in one or more files.  This example will
use two.

### Environment Variables for AWSCLI

To set your AWS credentials and your default region.  See the
[env-sample](https://github.com/OpenLMIS/openlmis-ref-distro/blob/master/utils/awscli/env-sample)
from there.  For our purposes we'll name it `aws.env`.

```
curl -L https://raw.githubusercontent.com/OpenLMIS/openlmis-ref-distro/master/utils/awscli/env-sample > aws.env
```

### Environment Variables for Restore Snapshot

This image adds the following additional enviornment variables:

* SNAPSHOT_NAME - the name of the RDS snapshot to restore from
* TARGET_INSTANCE - the name of the RDS instance to restore to (overwrite with snapshot)
* MASTER_USER_PASSWORD - the master user password of the restored instance.  You must set this,
  even if it's unchanged.
* SECURITY_GROUP - the security group name (e.g. sg-x12345) that the restored instance will use.

A [sample env file](env-sample) is included in this repo.

## example

Presuming we have env files:

* aws.env - has environment variables for awscli.
* restore.env - has environment variables for this image.

Then we could run:

```
docker run -it --rm --env-file aws.env --env-file restore.env openlmis/restore-snapshot
```
