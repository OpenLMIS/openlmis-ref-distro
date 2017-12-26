# OpenLMIS Taurus w/ yarn

This builds a Docker image based on [blazemeter/taurus](https://hub.docker.com/r/blazemeter/taurus/),
adding the yarn dependency to the image.

This only exists to simplify `yarn install` in containers that use it, and should be removed
should the upstream image starts to include yarn.
