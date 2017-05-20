==============
Architecture
==============

As of OpenLMIS v3, the `architecture <https://openlmis.atlassian.net/wiki/x/IYAKAw>`_
has transitioned to (micro) services fulfilling RESTful (HTTP) API requests
from a modularized Reference UI.  Extension mechanisms in addition to
microservices and UI modules further allow for components of the architecture
to be customized without the need for the community to fork the code base:

- UI modules give flexibility in creating new user experiences or changing existing ones
- Extension Points & Modules - allows Service functionality to be modified
- Extra Data - allows for extensions to store data with existing components

Combined these components allow the OpenLMIS community to customize and
contribute to a shared LMIS.

Docker
=======

Docker Engine and Docker Compose is utilized throughout the tech stack to
provide consistent builds, quicken environment setup and ensure that there are
clean boundaries between components.  Each deployable component is versioned
and published as a Docker Image to the public Docker Hub.  From this repository
of ready-to-run images on Docker Hub anyone may pull the image down to run the
component.

Development environments are typically started by running a single Service or
UI module's development docker compose.  Using docker compose allows the
component's author to specify the tooling and test runtime (e.g. PostgreSQL)
that's needed to compile, test and build and package the production docker
image that all implementation's are intended to use.

After a production docker image is produced, docker compose is used once again
in the Reference Distribution to combine the desired deployment images with the
needed configuration to produce an OpenLMIS deployment.

UI
===

.. toctree::
   :maxdepth: 1

   applicationStructure
   buildProcess
   extentionGuide
