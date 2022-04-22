==========
Components
==========

OpenLMIS v3 uses a micro-services :doc:`../architecture/index` with different services each providing
different APIs.

Each component below has its own Git repository, API docs and ERD. Many services below also have a
corresponding UI component (e.g. Auth UI, Requisition UI). The Reference UI builds all of these UI
components together into one web application.

***********************************
Logging into the Live Documentation
***********************************

The live documentation links below connect directly to our API Console docs on our CI server. To use
the API you'll first need to get an access token from the Auth service, and then you'll need to
give that token when using one of the RESTful operations.

Obtaining an access token:

1. Go to the Auth service's `POST /api/oauth/token <https://test.openlmis.org/auth/docs/>`_
2. Click :code:`Try it` in the top right of the tab
3. In the Authentication section, enter username :code:`user-client` and password :code:`changeme`
4. In the Query Parameters section, enter username :code:`administrator` and password
   :code:`password`
5. Click :code:`Authorize` under :code:`password`
6. Enter the username :code:`administrator` and password :code:`password`
7. Click :code:`Post`
8. In the :code:`Response` box, copy the UUID value of the :code:`access_token`.
   e.g. :code:`"access_token": "a93bcab7-aaf5-43fe-9301-76c526698898"`
   copy :code:`a93bcab7-aaf5-43fe-9301-76c526698898` to use later
9. Use the Authorization Token you just copied with every request.

   * In the live documentation using :code:`Try It`, type :code:`bearer` followed by the
     :code:`access_token` you copied earlier into the :code:`Authorization` header.
     e.g. :code:`bearer a93bcab7-aaf5-43fe-9301-76c526698898`
   * Alternatively, in any other HTTP request tool (e.g. Postman) you may append it in the query
     parameters using the :code:`access_token` field.
     e.g. :code:`GET https://test.openlmis.org/api/facilities?access_token=a93bcab7-aaf5-43fe-9301-76c526698898`

************
Auth Service
************

Auth Service provides RESTful API endpoints for Authentication and Authorization. It holds user
security credentials, handles password resets, and also manages API keys. It uses OAuth2. The
Auth Service works with the Reference Data service to handle role-based access controls.
(See the Auth Service README for details.)

- `Auth Service GitHub repo <https://github.com/OpenLMIS/openlmis-auth/>`_
- `Auth Service README <authService.html>`_
- `Auth Service Design <authServiceDesign.html>`_
- `Auth Service ERD <erd-auth.html>`_
- `Live Documentation for Auth API <http://test.openlmis.org/auth/docs/#/default>`_
- `Static Documentation for Auth API <http://build.openlmis.org/job/OpenLMIS-auth-pipeline/job/master/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

*******************
Fulfillment Service
*******************

Fulfillment Service provides RESTful API endpoints for orders, shipments, and proofs of delivery.
It supports fulfillment within OpenLMIS as well as external fulfillment using external ERP
warehouse systems.

- `Fulfillment Service GitHub repo <https://github.com/OpenLMIS/openlmis-fulfillment>`_
- `Fulfillment Service README <fulfillmentService.html>`_
- `Fulfillment ERD <erd-fulfillment.html>`_
- `Live Documentation for Fulfillment API <http://test.openlmis.org/fulfillment/docs/#/default>`_
- `Static Documentation for Fulfillment API <http://build.openlmis.org/job/OpenLMIS-fulfillment-pipeline/job/master/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

***********
CCE Service
***********

The Cold Chain Equipment (CCE) Service provides RESTful API endpoints for managing a CCE catalog,
inventory (tracking equipment at locations) and functional status. The catalog can use the `WHO PQS
<http://apps.who.int/immunization_standards/vaccine_quality/pqs_catalogue/>`_.

- `CCE Service GitHub repo <https://github.com/OpenLMIS/openlmis-cce>`_
- `CCE Service README <cceService.html>`_
- `CCE ERD <erd-cce.html>`_
- `Live Documentation for CCE API <http://test.openlmis.org/cce/docs/#/default>`_
- `Static Documentation for CCE API <http://build.openlmis.org/job/OpenLMIS-cce-pipeline/job/master/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

*****************
HAPI FHIR Service
*****************

The HAPI FHIR Service provides RESTful API endpoints for FHIR locations. It supports keeping
OpenLMIS facility data in sync with external facility registries through FHIR.

- `HAPI FHIR Service GitHub repo <https://github.com/OpenLMIS/openlmis-hapifhir>`_
- `HAPI FHIR Service README <hapifhirService.html>`_
- `Static Documentation for HAPI FHIR API <http://build.openlmis.org/job/OpenLMIS-hapifhir-pipeline/job/master/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

********************
Notification Service
********************

The Notification Service provides RESTful API endpoints that allow other OpenLMIS services to send
email notifications to users. The Notification Service does not provide a web UI.

- `Notification Service GitHub repo <https://github.com/OpenLMIS/openlmis-notification>`_
- `Notification Service README <notificationService.html>`_
- `Notification ERD <erd-notification.html>`_
- `Live Documentation for Notification API <http://test.openlmis.org/notification/docs/#/default>`_
- `Static Documentation for Notification API <http://build.openlmis.org/job/OpenLMIS-notification-pipeline/job/master/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

**********************
Reference Data Service
**********************

The Reference Data Service provides RESTful API endpoints that provide master lists of reference
data including users, facilities, programs, products, schedules, and more. Most other OpenLMIS
services depend on Reference Data Service. Many of these master lists can be loaded into OpenLMIS
in bulk using the `Reference Data Seed Tool <https://github.com/OpenLMIS/openlmis-refdata-seed>`_
or can be added and edited individually using the Reference Data Service APIs.

- `Reference Data Service GitHub repo <https://github.com/OpenLMIS/openlmis-referencedata/>`_
- `Reference Data Service README <referencedataService.html>`_
- `Reference Data ERD <erd-referencedata.html>`_
- `Live Documentation for Reference Data API <http://test.openlmis.org/referencedata/docs/#/default>`_
- `Static Documentation for Reference Data API <http://build.openlmis.org/job/OpenLMIS-referencedata-pipeline/job/master/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

************
Reference UI
************

The OpenLMIS Reference UI is a single page application that is compiled from multiple UI
repositories. The Reference UI is similar to the OpenLMIS-Ref-Distro, in that it's an example
deployment for implementers to use.

Learn about the Reference UI:

- `OpenLMIS UI Overview <uiOverview.html>`_ describes the UI architecture and tooling
- `UI Styleguide <http://build.openlmis.org/job/OpenLMIS-ui-components-pipeline/job/master/lastSuccessfulBuild/artifact/build/styleguide/index.html>`_
  shows examples and best practices for many re-usable components
- `Dev UI <devUI.html>`_ documents the build process and commands used by all UI components

Coding and Customizing the UI:

- `UI Extension Guide <uiExtensionGuide.html>`_
- UI :doc:`../conventions/index`
- `Javascript Documentation <http://build.openlmis.org/job/OpenLMIS-reference-ui-pipeline/job/master/lastSuccessfulBuild/artifact/build/docs/index.html#/api>`_

UI Repositories:

- `Reference UI <referenceUI.html>`_ puts all the UI repositories into one single page application
  (`Reference UI GitHub repo <https://github.com/OpenLMIS/openlmis-reference-ui>`_)
- `Dev UI <devUI.html>`_ provides the build tools and commands. All other UI repositories use these
  build tools by including Dev UI as a base image in docker-compose.
  (`Dev UI GitHub repo <https://github.com/OpenLMIS/dev-ui>`_)
- `UI Components <uiComponents.html>`_ is where OpenLMIS reusable components are defined along with
  base CSS styles (`UI Components GitHub repo <https://github.com/OpenLMIS/openlmis-ui-components>`_)
- `Auth UI <authUI.html>`_ connects the OpenLMIS UI to the OpenLMIS Auth Service and handles all
  authentication details so other UI repositories don't have to (`Auth UI GitHub repo
  <https://github.com/OpenLMIS/openlmis-auth-ui/>`_)
- `UI Layout <uiLayout.html>`_ defines UI layouts and page architecture used in the OpenLMIS UI
  (`UI Layout GitHub repo <https://github.com/OpenLMIS/openlmis-ui-layout>`_)
- `Reference Data UI <referencedataUI.html>`_ adds administration screens for objects defined in
  the OpenLMIS Reference Data Service (`Reference Data UI GitHub repo
  <https://github.com/OpenLMIS/openlmis-referencedata-ui>`_)
- `Stock Management UI <stockmanagementUI.html>`_ adds screens to interact with the OpenLMIS Stock
  Management Service (`Stock Management UI GitHub repo
  <https://github.com/OpenLMIS/openlmis-stockmanagement-ui>`_)
- `Fulfillment UI <fulfillmentUI.html>`_ adds screens to connect to the OpenLMIS Fulfillment Service
  (`Fulfillment UI GitHub repo <https://github.com/OpenLMIS/openlmis-fulfillment-ui>`_)
- `CCE UI <cceUI.html>`_ adds screens for the OpenLMIS CCE Service. (`CCE UI GitHub repo
  <https://github.com/OpenLMIS/openlmis-cce-ui>`_)
- `Requisition UI <requisitionUI.html>`_ adds screens to support the OpenLMIS Requisition Service
  (`Requisition UI GitHub repo <https://github.com/OpenLMIS/openlmis-requisition-ui>`_)
- `Report UI <reportUI.html>`_ adds screens to interact with OpenLMIS Report Service (`Report UI
  GitHub repo <https://github.com/OpenLMIS/openlmis-report-ui>`_)

**************
Report Service
**************

The Report Service provides RESTful API endpoints for generating printed / banded reports. It owns
report storage, generation (including in PDF format), and seeding rights that users may be given.

- `Report Service GitHub repo <https://github.com/OpenLMIS/openlmis-report/>`_
- `Report Service README <reportService.html>`_
- `Report ERD <erd-report.html>`_
- `Live Documentation for Report API <http://test.openlmis.org/report/docs/#/default>`_
- `Static Documentation for Report API <http://build.openlmis.org/job/OpenLMIS-report-pipeline/job/master/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

*******************
Requisition Service
*******************

The Requisition Service provides RESTful API endpoints for a robust requisition workflow used in
pull-based supply chains for requesting more stock on a schedule through an administrative
hierarchy. Requisitions are initiated, filled out, submitted, and approved based on configuration.
Requisition Templates control what information is collected on the Requisition form for different
programs and facilities.

- `Requisition Service GitHub repo <https://github.com/OpenLMIS/openlmis-requisition>`_
- `Requisition Service README <requisitionService.html>`_
- `Requisition ERD <erd-requisition.html>`_
- `Live Documentation for Requisition API <http://test.openlmis.org/requisition/docs/#/default>`_
- `Static Documentation for Requisition API <http://build.openlmis.org/job/OpenLMIS-requisition-pipeline/job/master/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

************************
Stock Management Service
************************

The Stock Management Service provides RESTful API endpoints for creating electronic stock cards and
recording stock transactions over time.

- `Stock Management Service GitHub repo <https://github.com/OpenLMIS/openlmis-stockmanagement>`_
- `Stock Management Service README <stockmanagementService.html>`_
- `Stock Management ERD <erd-stockmanagement.html>`_
- `Live Documentation for Stock Management API <http://test.openlmis.org/stockmanagement/docs/#/default>`_
- `Static Documentation for Stock Management API <http://build.openlmis.org/job/OpenLMIS-stockmanagement-pipeline/job/master/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

*******************
Diagnostics Service
*******************

The Diagnostics Service provides RESTful API endpoints for checking the system health.

- `Diagnostics Service GitHub repo <https://github.com/OpenLMIS/openlmis-diagnostics>`_
- `Diagnostics Service README <diagnosticsService.html>`_
- `Static Documentation for Diagnostics API <http://build.openlmis.org/job/OpenLMIS-diagnostics-pipeline/job/master/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

********************************
Reporting and Analytics Platform
********************************

OpenLMIS includes a reporting and analytics platform that extracts the data from each microservice, streams it to a data warehouse and provides a scalable reporting and dashboard interface. This reporting platform is made of multiple open source components, Apache Nifi, Apache Kafka, Druid and Apache SuperSet. This section provides an overview of each of the components of the reporting and analytics platform.

----
Nifi
----

`NiFi <https://nifi.apache.org/>`_ is used for pulling data from OpenLMIS’s APIs, merging data from the APIs into a single schema, and transforming the data into a format that’s easy to query in Druid. Currently, NiFi blends data from the stockCardSummaries API and the referenceData API. It splits stock cards into line items and merges reference data with those line items, to have a single schema where stock card transactions (line items) contain detailed reference data like facility name, commodity type name, etc. instead of the reference data ids that natively live on the transaction in the stock management module. NiFi functions like an assembly line, where data moves from “processor” to processor throughout the “flow file.”

-----
Kafka
-----

`Kafka <https://kafka.apache.org/>`_ is used for stream processing and passing the data from NiFi to Druid. It works on a publish-subscribe model, similar to how message queues in an enterprise messaging systems work. Kafka is run on a cluster on one or more servers. A Kafka cluster stores streams of “records” in categories called “topics.” A record consists of three parts: a key, a value, and a timestamp. A Kafka topic receives the transformed transaction from NiFi and publishes it to the Druid “supervisor.” The Druid supervisor is always listening for updates from Kafka, and indexes the data immediately.

-----
Druid
-----

`Druid <http://druid.io/>`_ is a distributed column-oriented OLAP database that the reporting stack uses for data storage and querying. Druid is purpose-built for querying streaming data sets at scale. Each set of data is called a “data source.” JSON is the default language used for querying in Druid and is what the DISC indicators use. Druid also includes support for `SQL <http://druid.io/docs/latest/querying/sql.html>`_ using `Apache Calcite <https://calcite.apache.org/>`_, although this is not yet something we’ve explored. You can find documentation on querying in Druid using JSON `here <http://druid.io/docs/latest/querying/querying.html>`_.

--------
Superset
--------

`Superset <https://superset.apache.org/>`_ is the visualization layer of the reporting stack and is used to create self-service dashboards on the data in Druid. It’s very closely integrated with Druid, and will detect the schema for each data source and the data therein. “Dimensions” are akin to columns within a relational database, and “metrics” are calculations performed on those dimensions - e.g. count distinct, sum, min, max. Typically “metrics” are written off of numeric dimensions, with the exception of count distinct. Superset is the UI in which we write JSON queries for Druid to calculate metrics that are more sophisticated than the basic types outlined above.

Slices are individual visualizations and can be listed by clicking on the Charts tab along the top. Each slice has a visualization type, a data source, and one or more metrics and dimensions that you want to display. Superset supports the development of custom visualization types if it’s not included in the default list provided by Apache.

A dashboard is an assembly of slices onto a single page. Filters can be applied at the dashboard-level, and filter all slices sharing the filter’s data source to the specified dimension. Filters can also be used to manipulate date ranges. With proper security (more information below), users can save custom private or public versions of dashboards, and drill into a particular slice to modify it and construct an ad hoc visualization.

Security is handled via User Roles and Users. A User is a distinct login with a password, and is tied to an email address. There can only be one User per email address. A User Role is the list of actions that a User can do in Superset. Superset contains three User Roles by default, but they can be customized by duplicating the defaults and adding or removing permissions.

- Gamma - a view-only user who can save private views of dashboards and slices
- Alpha - a power user who is able to view all data sources, and create public dashboards and slices
- Admin - administrator with all access
