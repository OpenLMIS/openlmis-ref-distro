==============
Architecture
==============

As of OpenLMIS v3, the `architecture`_
has transitioned to (micro) services fulfilling RESTful (HTTP) API requests.
A modularized Reference UI application runs in a browser and uses those APIs
to expose functionality to end users. Other systems and mobile apps may also
use the APIs to integrate and provide functionality. A Reporting and Analytics 
Platform uses a data warehouse strategy to offer visualizations of OpenLMIS
data.

Extension mechanisms allow for components of the architecture
to be customized without the need for the community to fork the code base:

- UI modules give flexibility in creating new user experiences or changing existing ones
- Extension Points & Modules - allows Service/API functionality to be modified
- Extra Data - allows for extensions to store data with existing components
- Reporting and Analytics Platform - allows for robust reporting solutions to be developed to meet implementation needs

Combined these components allow the OpenLMIS community to customize and
contribute to a shared LMIS.

Interoperability
=================

Read more on `Interoperability <interop.html>`_.

.. toctree::
   :maxdepth: 2

   interop

New Service Guidelines
=======================

OpenLMIS' Service `architecture`_ is centered around the concept of
`Bounded Contexts`_.  In this pattern we identify
Service's by grouping similar *things* (noun) into a Service, and define a clear boundary between
that Service and others.  Where to draw this line, and decide when to create a new Service or when
to contribute to/extend an existing Service can sometimes be difficult to judge.

A quick set of guidelines for a OpenLMIS Service:

- A Service owns its data.  For example the Requisition Service owns all the data that pertains to
  a Requisition and moving it through the workflow.  It depends on information to help it along:
  facilities, programs, user's, etc.  While these *things* are needed for a Requisition, they aren't
  inherently a Requisition's *things*.  The Requisition service owns Requisition *things*:
  Requisitions and their Line Items, Requisition Templates, etc.  It coordinates with other OpenLMIS
  Service's to obtain references of those other *things* it needs, that it doesn't own.
- A Service owns `transactions`_. Operations on a Service's *things* almost always occur within a
  transaction.  We read the state of a Requisition or write new state about that Requisition.
  Other Service's may become involved, however the transaction as it appears to the User is owned
  by the original Service.
- Service's backing data stores (usually relational databases) do not know about one-another.  Only
  Service's know about other Services.  Because of this it's the responsibility of the Services
  for maintaining `referential integrity`_, as Foreign Key's can't cross Services's databases.

When considering creating a new Service, consider if that Service really owns its own *things*,
and should be implemented as an OpenLMIS Service, or if instead the functionality needed is a
re-use of existing *things* in a new way, in which case a contribution/extension should be made to
an existing OpenLMIS Service. OpenLMIS does not follow `Serverless architecture`_ at this time.


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


.. _Architecture: https://openlmis.atlassian.net/wiki/x/IYAKAw
.. _Interoperability: 
.. _Bounded Contexts: https://martinfowler.com/bliki/BoundedContext.html
.. _referential integrity: https://en.wikipedia.org/wiki/Referential_integrity
.. _transactions: https://en.wikipedia.org/wiki/ACID
.. _Serverless architecture: https://martinfowler.com/articles/serverless.html
