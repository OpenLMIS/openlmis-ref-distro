======================================
3.2.0 Release Notes - 1 September 2017
======================================

Status: Stable
==============

3.2.0 is a stable release, and all users of `OpenLMIS version 3
<https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017>`_ are
encouraged to adopt it.

Release Notes
=============

The OpenLMIS Community is excited to announce the **3.2.0 release** of OpenLMIS!

This release represents another major milestone in the version 3 series, which is the result of a
software `re-architecture <https://openlmis.atlassian.net/wiki/display/OP/Re-Architecture>`_ that
allows more functionality to be shared among the community of OpenLMIS users.

3.2.0 includes new features in **stock management**, new **administrative screens**, targeted **performance improvements** and a beta version of the **Cold Chain Equipment (CCE)** service and more contributions in the form of pull requests, from the **Malawi implementation**, a national implementation is now live on OpenLMIS version 3.

3.2.0 represents the first milestone towards the `Vaccines MVP
<https://openlmis.atlassian.net/wiki/spaces/OP/pages/113144940/Vaccine+MVP>`_ feature set. 

After 3.2.0, there are further planned `milestone releases and patch releases
<http://docs.openlmis.org/en/latest/conventions/versioningReleasing.html>`_ that will add more
features to support Vaccine/EPI programs and continue making OpenLMIS a full-featured electronic
logistics management information system (LMIS). Please reference the `Living Product Roadmap
<https://openlmis.atlassian.net/wiki/display/OP/Living+Product+Roadmap>`_ for the upcoming release
priorities. Patch releases will continue to include bug fixes, performance improvements, and pull
requests are welcomed.

Compatibility
-------------

All changes are backwards-compatible. Any changes to data include automated migrations from previous
versions back to version 3.0.1. Any exceptions are identified in the Components sections below.

**Important**: 3.2.0 contains a data migration script that must be applied in order to upgrade from
older version 3 to 3.2.0. This migration has its own GitHub repo and Docker image. See
`Adjustment Reason Migration <https://github.com/OpenLMIS/openlmis-adjustment-reason-migration>`_.

For background information on OpenLMIS version 3's micro-service architecture,
extensions/customizations, and upgrade paths for OpenLMIS versions 1 and 2, see the `3.0.0 Release
Notes <https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017>`_.

Download or View on GitHub
--------------------------

`OpenLMIS Reference Distribution 3.2.0
<https://github.com/OpenLMIS/openlmis-ref-distro/releases/tag/v3.2.0>`_

New Features
============

This is a new section to flag all the new features. 

* **Stock Management**: is not an official release and added a notification and new support for recording VVM status.
* **Administrative Screens**: view supply lines, geogrphic zones, requisition groups and program settings.
* beta version of the new **Cold Chain Equipment (CCE)** service: which includes the support to upload a catalog of cold chain equipment, add equpiment inventory (from the catalog) to facilities, and manually update the functional status of that equipment.  Review the `wiki <https://openlmis.atlassian.net/wiki/spaces/OP/pages/113145252/Cold+Chain+Equipment+Management>`_ for details on the upcoming features.
* **Performance** - targeted improvements were made based on the first implementation's use and results. Improvements were made in server response times, which impacts load time, and memory utilization. In addition, new tooling was introduced to provide the ability to track performance improvements and bottlenecks. 
* Reference data
* Report service is now its own separate component to provide reporting features (**TBD**)

Changes to Existing Functionality
=================================

Version 3.2.0 contains changes that impact users of existing functionality. Please review these
changes which may require informing end-users and/or updating your customizations/extensions:

- Requisition Service now uses Stock Management to handle adjustment reasons and to store
  stock data in stock cards. This change does not alter end-user functionality in Requisitions,
  but it does allow users with Stock Management rights to begin viewing stock cards with data
  populated from requisitions. This change also requires a data migration script to upgrade olderx
  version 3 systems to 3.2.0. (See Requisition component below.)

API Changes
===========

Some APIs have changes to their contracts and/or their request-response data structures. These
changes impact developers and systems integrating with OpenLMIS:

- Auth Service uses Authorization header instead of access_token (see Auth OLMIS-2871 below)
- Fulfillment Service and Requisition Service changed some dates from ZonedDateTime to LocalDate
  (see OLMIS-2898 below)
- ReferenceData contains changes to Facility search and Geographic Search APIs (see component below)
- Requisition Service now requires use of the Stock Management service and connects to Stock
  service to handle adjustment reasons and store data on stock cards (see Requisition component)
- Configuration settings endpoints (/api/settings) are no longer available; use environment
  variables to configure the application (see OLMIS-2612 below)
- postgres database now requires one additional extension: uuid. It is already included in the
  postgres component (see postgres component below), but those hosting on Amazon AWS RDS will need
  to add the extension.

All Changes by Component
========================

Version 3.2.0 of the Reference Distribution contains updated versions of the components listed
below. The Reference Distribution bundles these component together using Docker to create a complete
OpenLMIS instance. Each component has its own own public GitHub repository (source code) and
DockerHub repository (release image). The Reference Distribution and components are versioned
independently; for details see `Versioning and Releasing
<http://docs.openlmis.org/en/latest/conventions/versioningReleasing.html>`_.

Auth Service 3.1.0
------------------

Improvements which are backwards-compatible:

- `OLMIS-1498 <https://openlmis.atlassian.net/browse/OLMIS-1498>`_: The service will now fetch list
  of available services from consul, and update OAuth2 resources dynamically when a new service is
  registered or de-registered. Those tokens are no longer hard-coded.
- `OLMIS-2866 <https://openlmis.atlassian.net/browse/OLMIS-2866>`_: The service will no longer used
  self-contained user roles (USER, ADMIN), and depend solely on referencedata's roles for user
  management.
- `OLMIS-2871 <https://openlmis.atlassian.net/browse/OLMIS-2871>`_: The service now uses an
  Authorization header instead of an access_token request parameter when communicating with other
  services.

Source: `Auth CHANGELOG <https://github.com/OpenLMIS/openlmis-auth/blob/master/CHANGELOG.md>`_

CCE Service 1.0.0-beta
----------------------

This component is a **beta** of new Cold Chain Equipment functionality to support Vaccines in
medical supply chains. This API service component has an accompanying beta CCE UI component.

CCE 1.0.0-beta includes many new features:

- Configuring a cold chain equipment catalog
- Managing cold chain equipment inventory
- Capturing functionality status of equipment

For details, see the functional documentation: `Cold Chain Equipment Management
<https://openlmis.atlassian.net/wiki/spaces/OP/pages/113145252/Cold+Chain+Equipment+Management>`_

*Warning: This is a beta component, and is not yet intended for production use. APIs and
functionality are still subject to change until the official release.*

Fulfillment Service 6.0.0
-------------------------

Contract breaking changes:

- `OLMIS-2898 <https://openlmis.atlassian.net/browse/OLMIS-2898>`_: Changed POD receivedDate from
  ZonedDateTime to LocalDate.

New functionality added in a backwards-compatible manner:

- `OLMIS-2724 <https://openlmis.atlassian.net/browse/OLMIS-2724>`_: Added an endpoint for retrieving
  all the available, distinct requesting facilities.

Bug fixes and improvements (backwards-compatible):

- `OLMIS-2871 <https://openlmis.atlassian.net/browse/OLMIS-2871>`_: The service now uses an
  Authorization header instead of an access_token request parameter when communicating with other
  services.
- `OLMIS-3059 <https://openlmis.atlassian.net/browse/OLMIS-3059>`_: The search orders endpoint now
  sorts the orders by created date property (most recent first).

Source: `Fulfillment CHANGELOG
<https://github.com/OpenLMIS/openlmis-fulfillment/blob/master/CHANGELOG.md>`_

nginx
--------

**TBD**

Notification Service 3.1.0
--------------------------

Bug fixes, security and performance improvements (backwards-compatible):

- `OLMIS-2871 <https://openlmis.atlassian.net/browse/OLMIS-2871>`_: The service now uses an
  Authorization header instead of an access_token request parameter when communicating with other
  services.

Source: `Notification CHANGELOG
<https://github.com/OpenLMIS/openlmis-notification/blob/master/CHANGELOG.md>`_

postgres
--------

**TBD**: explain new version and link to documentation about adding uuid extension

Reference Data Service 8.0.0
----------------------------

Breaking changes:

- `OLMIS-2709 <https://openlmis.atlassian.net/browse/OLMIS-2709>`_: Facility search now returns
  smaller objects.
- `OLMIS-2698 <https://openlmis.atlassian.net/browse/OLMIS-2698>`_: Geographic Zone search endpoint
  now is paginated and accepts POST requests, also has new parameters: name and code.

New functionality added in a backwards-compatible manner:

- `OLMIS-2609 <https://openlmis.atlassian.net/browse/OLMIS-2609>`_: Created rights to manage CCE and
  assigned to system administrator.
- `OLMIS-2610 <https://openlmis.atlassian.net/browse/OLMIS-2610>`_: Added CCE Inventory View/Edit
  rights, added demo data for those rights.
- `OLMIS-2696 <https://openlmis.atlassian.net/browse/OLMIS-2696>`_: Added search requisition groups
  endpoint.
- `OLMIS-2780 <https://openlmis.atlassian.net/browse/OLMIS-2780>`_: Added endpoint for getting all
  facilities with minimal representation.
- Introduced JaVers to all domain entities. Also each domain entity has endpoint to get the audit
  information.
- `OLMIS-3023 <https://openlmis.atlassian.net/browse/OLMIS-3023>`_: Added
  enableDatePhysicalStockCountCompleted field to program settings.
- `OLMIS-2619 <https://openlmis.atlassian.net/browse/OLMIS-2619>`_: Added CCE Manager role and
  assigned CCE Manager and Inventory Manager roles to new user ccemanager.

Bug fixes, security and performance improvements, also backwards-compatible:

- `OLMIS-2871 <https://openlmis.atlassian.net/browse/OLMIS-2871>`_: The service now uses an
  Authorization header instead of an access_token request parameter when communicating with other
  services.
- `OLMIS-2534 <https://openlmis.atlassian.net/browse/OLMIS-2534>`_: Fixed potential huge performance
  issue.
- `OLMIS-2716 <https://openlmis.atlassian.net/browse/OLMIS-2716>`_: Set productCode field in
  Orderable as unique.

Source: `ReferenceData CHANGELOG
<https://github.com/OpenLMIS/openlmis-referencedata/blob/master/CHANGELOG.md>`_

Reference UI 6.0.0
------------------

The Reference UI bundles the following UI components together using Docker images specified in its
`compose file <https://github.com/OpenLMIS/openlmis-reference-ui/blob/master/docker-compose.yml>`_.

auth-ui 5.0.3
~~~~~~~~~~~~~

See `openlmis-auth-ui CHANGELOG
<https://github.com/OpenLMIS/openlmis-auth-ui/blob/master/CHANGELOG.md>`_

cce-ui 1.0.0-beta
~~~~~~~~~~~~~~~~~

Beta release of `CCE UI <https://github.com/OpenLMIS/openlmis-cce-ui>`_. See CCE service component
below for more info.

fulfillment-ui 5.0.3
~~~~~~~~~~~~~~~~~~~~

See `openlmis-fulfillment-ui CHANGELOG
<https://github.com/OpenLMIS/openlmis-fulfillment-ui/blob/master/CHANGELOG.md>`_

referencedata-ui 5.2.1
~~~~~~~~~~~~~~~~~~~~~~

See `openlmis-referencedata-ui CHANGELOG
<https://github.com/OpenLMIS/openlmis-referencedata-ui/blob/master/CHANGELOG.md>`_

report-ui 5.0.3
~~~~~~~~~~~~~~~

See `openlmis-report-ui CHANGELOG
<https://github.com/OpenLMIS/openlmis-report-ui/blob/master/CHANGELOG.md>`_

requisition-ui 5.1.1
~~~~~~~~~~~~~~~~~~~~

See `openlmis-requisition-ui CHANGELOG
<https://github.com/OpenLMIS/openlmis-requisition-ui/blob/master/CHANGELOG.md>`_

stockmanagement-ui 1.0.0
~~~~~~~~~~~~~~~~~~~~~~~~

First release of `Stock Management UI <https://github.com/OpenLMIS/openlmis-stockmanagement-ui>`_.
See Stock Management service component below for more info.

ui-components 5.1.1
~~~~~~~~~~~~~~~~~~~

See `openlmis-ui-components CHANGELOG
<https://github.com/OpenLMIS/openlmis-ui-components/blob/master/CHANGELOG.md>`_

ui-layout:5.0.2
~~~~~~~~~~~~~~~

See `openlmis-ui-layout CHANGELOG
<https://github.com/OpenLMIS/openlmis-ui-layout/blob/master/CHANGELOG.md>`_

Report Service 1.0.0
--------------------

**TBD**

Requisition Service 5.0.0
-------------------------

Contract breaking changes:

- `OLMIS-2612 <https://openlmis.atlassian.net/browse/OLMIS-2612>`_: Configuration settings endpoints
  (/api/settings) are no longer available. Use environment variables to configure the application.
- `MW-365 <https://openlmis.atlassian.net/browse/MW-365>`_: Requisition search endpoints:
  requisitionsForApproval and requisitionsForConvert will now return smaller basic dtos.
- `OLMIS-2833 <https://openlmis.atlassian.net/browse/OLMIS-2833>`_: Added date physical stock count
  completed to Requisition
- `OLMIS-2671 <https://openlmis.atlassian.net/browse/OLMIS-2671>`_: Stock Management service is now
  required by Requisition
- `OLMIS-2694 <https://openlmis.atlassian.net/browse/OLMIS-2694>`_: Changed Requisition adjustment
  reasons to come from Stock Service
- `OLMIS-2898 <https://openlmis.atlassian.net/browse/OLMIS-2898>`_: Requisition search endpoint
  takes from/to parameters as dates without time part.
- `OLMIS-2830 <https://openlmis.atlassian.net/browse/OLMIS-2830>`_: As of this version, Requisition
  now uses Stock Management as the source for adjustment reasons, moreover it stores snapshots of
  these available reasons during initiation. **Important**: in order to migrate from older versions,
  running this migration is required: https://github.com/OpenLMIS/openlmis-adjustment-reason-migration

New functionality added in a backwards-compatible manner:

- `OLMIS-2709 <https://openlmis.atlassian.net/browse/OLMIS-2709>`_: Changed ReferenceData facility
  service search endpoint to use smaller dto.
- The /requisitions/requisitionsForConvert endpoint accepts several sortBy parameters. Data returned
  by the endpoint will be sorted by those parameters in order of occurrence. By defaults data will
  be sorted by emergency flag and program name.
- `OLMIS-2928 <https://openlmis.atlassian.net/browse/OLMIS-2928>`_: Introduced new batch endpoints,
  that allow retrieval and approval of several requisitions at once. This also refactored the error
  handling.

Bug fixes added in a backwards-compatible manner:

- `OLMIS-2788 <https://openlmis.atlassian.net/browse/OLMIS-2788>`_: Fixed print requisition.
- `OLMIS-2747 <https://openlmis.atlassian.net/browse/OLMIS-2747>`_: Fixed bug preventing user from
  being able to re-initiate a requisition after being removed, when there's already a requisition
  for next period.
- `OLMIS-2871 <https://openlmis.atlassian.net/browse/OLMIS-2871>`_: The service now uses an
  Authorization header instead of an access_token request parameter when communicating with other
  services.
- `OLMIS-2534 <https://openlmis.atlassian.net/browse/OLMIS-2534>`_: Fixed potential huge performance
  issue. The javers log initializer will not retrieve all domain objects at once if a repository
  implemenets PagingAndSortingRepository
- `OLMIS-3008 <https://openlmis.atlassian.net/browse/OLMIS-3008>`_: Add correct error message when
  trying to convert requisition to an order with approved quantity disabled in the the requisition
  template.
- `OLMIS-2908 <https://openlmis.atlassian.net/browse/OLMIS-2908>`_: Added a unique partial index on
  requisitions, which prevents creation of requisitions which have the same facility, program and
  processing period while being a non-emergency requsition. This is now enforced by the database,
  not only the application logic.
- `OLMIS-3019 <https://openlmis.atlassian.net/browse/OLMIS-3019>`_: Removed clearance of beginning
  balance and price per pack fields from skipped line items while authorizing.

Source: `Requisition CHANGELOG
<https://github.com/OpenLMIS/openlmis-requisition/blob/master/CHANGELOG.md>`_

Stock Management 1.0.0
----------------------

This is the **first official release** of the new Stock Management service. Its beta version was
previously released in Reference Distribution 3.1.0. Since then, the major improvements are:

- `OLMIS-2710 <https://openlmis.atlassian.net/browse/OLMIS-2710>`_: Configure VVM use per product
- `OLMIS-2654 <https://openlmis.atlassian.net/browse/OLMIS-2654>`_ and `OLMIS-2663
  <https://openlmis.atlassian.net/browse/OLMIS-2663>`_: Record VVM status with physical
  stock count and adjustments
- `OLMIS-2711 <https://openlmis.atlassian.net/browse/OLMIS-2711>`_: Change Physical Inventory to
  include reasons for discrepancy
- `OLMIS-2834 <https://openlmis.atlassian.net/browse/OLMIS-2834>`_: Requisition form info gets
  pushed into Stock cards (see more in Requisition component)
- *plus lots of technical work including Flyway migrations, RAML, tests, validations, translations,
  documentation, and demo data.*

Watch a video demo of the Stock Management functionality:
https://www.youtube.com/watch?v=QMcXX3tUTHE (English) or
https://www.youtube.com/watch?v=G8BK0izxbnQ (French)

Now that this is an official release, the Stock service is considered stable for production use.
Future changes to functionality or APIs will be tracked and documented.

For a list of all commits since 1.0.0-beta, see `GitHub commits
<https://github.com/OpenLMIS/openlmis-stockmanagement/commits/master>`_

Components with No Changes
==========================

Other tooling components have not changed, including: the `logging service
<https://github.com/OpenLMIS/openlmis-rsyslog>`_ and a library for shared Java code called
`service-util <https://github.com/OpenLMIS/openlmis-service-util>`_.

Contributions
=============

Thanks to the Malawi implementation team who has continued contributing many pull requests to add
functionality, performance improvements, and customization in ways that have global shared benefit.
Also, thanks to everyone who contributed to `OpenLMIS 3.0.0 
<https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017#id-3.0.0Release-1March2017-Contributors>`_.

Further Resources
=================

View all `JIRA Tickets in 3.2.0 <https://openlmis.atlassian.net/issues/?jql=statusCategory%20%3D%20d
one%20AND%20project%20%3D%2011100%20AND%20fixVersion%20%3D%203.2%20ORDER%20BY%20type%20ASC%2C%20prio
rity%20DESC%2C%20key%20ASC>`_.

Learn more about the `OpenLMIS Community <http://openlmis.org/about/community/>`_ and how to get
involved!
