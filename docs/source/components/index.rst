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

The live documentation links below connect directly to our Swagger docs on our CI server.  To use
the API you'll first need to get an access token from the Auth service, and then you'll need to
give that token when using one of the RESTful operations.

Obtaining an access token:

1. go to the Auth service's `POST /api/oauth/token <https://test.openlmis.org/auth/docs/#!/default/post_api_oauth_token>`_
2. click on :code:`Authorize` in the top right of the page
3. in the box that has popped-up, enter username :code:`user-client` and password :code:`changeme`
4. click :code:`Authorize` under :code:`password`
5. enter the username :code:`administrator` and password :code:`password`
6. click :code:`Try it out!`
7. In the :code:`Response body` box, copy the UUID.  e.g. :code:`"access_token": "a93bcab7-aaf5-43fe-9301-76c526698898"` copy :code:`a93bcab7-aaf5-43fe-9301-76c526698898` to use later.
8. Paste the UUID you just copied into any endpoint's :code:`access_token` field.

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
- `Static Documentation for Auth API <http://build.openlmis.org/job/OpenLMIS-auth-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

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
- `Static Documentation for Fulfillment API <http://build.openlmis.org/job/OpenLMIS-fulfillment-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

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
- `Static Documentation for CCE API <http://build.openlmis.org/job/OpenLMIS-cce-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

********************
Notification Service
********************

The Notification Service provides RESTful API endpoints that allow other OpenLMIS services to send
email notifications to users. The Notification Service does not provide a web UI.

- `Notification Service GitHub repo <https://github.com/OpenLMIS/openlmis-notification>`_
- `Notification Service README <notificationService.html>`_
- `Live Documentation for Notification API <http://test.openlmis.org/notification/docs/#/default>`_
- `Static Documentation for Notification API <http://build.openlmis.org/job/OpenLMIS-notification-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

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
- `Static Documentation for Reference Data API <http://build.openlmis.org/job/OpenLMIS-referencedata-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_


************
Reference UI
************

The OpenLMIS Reference-UI is a single page application that is compiled from multiple UI repositories. The Reference-UI is similar to the OpenLMIS-Ref-Distro, in that it's an example deployment for implementers to use not something to fork or copy.

Learn about the Reference-UI

- `Reference UI GitHub repo <https://github.com/OpenLMIS/openlmis-reference-ui>`_
- `Reference UI README <referenceUI.html>`_

UI Repositories Overview:

- `Dev UI <devUI.html>`_ is where the UI build process and tooling are defined. All other UI repositories use this build process. `Dev UI GitHub repo <https://github.com/OpenLMIS/dev-ui>`_
- `UI Components <uiComponents.html>`_ is where OpenLMIS reusable components are defined, along with base CSS styles. `UI Components GitHub repo <https://github.com/OpenLMIS/openlmis-ui-components>`_
- `Auth UI <authUI.html>`_ connects the OpenLMIS-UI to the OpenLMIS Auth Service, and handles all authentication related details so other UI repositories don't have to. `Auth UI GitHub repo <https://github.com/OpenLMIS/openlmis-auth-ui/>`_
- `UI Layout <uiLayout.html>`_ creates UI layouts and page architecture used in the OpenLMIS-UI. `UI Layout GitHub repo <https://github.com/OpenLMIS/openlmis-ui-layout>`_
- `Reference Data UI <referencedataUI.html>`_ adds administration screens for objects defined in the OpenLMIS Reference Data Service. `Reference Data UI GitHub repo <https://github.com/OpenLMIS/openlmis-referencedata-ui>`_
- `Stock Management UI <stockmanagementUI.html>`_ adds screens to interact with the OpenLMIS Stock Management Service. `Stock Management UI GitHub repo <https://github.com/OpenLMIS/openlmis-stockmanagement-ui>`_
- `Fulfillment UI <fulfillmentUI.html>`_ adds screens to connect to the OpenLMIS Fulfillment Service. `Fulfillment UI GitHub repo <https://github.com/OpenLMIS/openlmis-fulfillment-ui>`_
- `CCE UI <cceUI.html>`_ adds screens to the OpenLMIS CCE Service. `CCE UI GitHub repo <https://github.com/OpenLMIS/openlmis-cce-ui>`_
- `Requisition UI <requisitionUI.html>`_ adds screens to support the OpenLMIS Requisition Service. `Requisition UI GitHub repo <https://github.com/OpenLMIS/openlmis-requisition-ui>`_
- `Report UI <reportUI.html>`_ adds screens to interact with OpenLMIS Report Service. `Report UI GitHub repo <https://github.com/OpenLMIS/openlmis-report-ui>`_

UI Documentation:

- `UI Styleguide <http://build.openlmis.org/job/OpenLMIS-ui-components/lastSuccessfulBuild/artifact/build/styleguide/index.html>`_
- `Javascript Documentation <http://build.openlmis.org/job/OpenLMIS-reference-ui/lastSuccessfulBuild/artifact/build/docs/index.html#/api>`_


**************
Report Service
**************

The Report Service provides RESTful API endpoints for generating printed / banded reports. It owns
report storage, generation (including in PDF format), and seeding rights that users may be given.

- `Report Service GitHub repo <https://github.com/OpenLMIS/openlmis-report/>`_
- `Report Service README <reportService.html>`_
- `Report ERD <erd-report.html>`_
- `Live Documentation for Report API <http://test.openlmis.org/report/docs/#/default>`_
- `Static Documentation for Report API <http://build.openlmis.org/job/OpenLMIS-report-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

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
- `Static Documentation for Requisition API <http://build.openlmis.org/job/OpenLMIS-requisition-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

************************
Stock Management Service
************************

The Stock Management Service provides RESTful API endpoints for creating electronic stock cards and
recording stock transactions over time.

- `Stock Management Service GitHub repo <https://github.com/OpenLMIS/openlmis-stockmanagement>`_
- `Stock Management Service README <stockmanagementService.html>`_
- `Stock Management ERD <erd-stockmanagement.html>`_
- `Live Documentation for Stock Management API <http://test.openlmis.org/stockmanagement/docs/#/default>`_
- `Static Documentation for Stock Management API <http://build.openlmis.org/job/OpenLMIS-stockmanagement-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_
