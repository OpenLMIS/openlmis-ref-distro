==========
Components
==========

**********************************
How to use Component Documentation
**********************************

Logging in with the Live Documentation
======================================

The live documentation links connect directly to our Swagger docs on our CI server.  To use the API you'll first need to get an
access token from the Auth service, and then you'll need to give that token when using one of the RESTful operations.

Obtaining an access token:

1. goto the Auth service's `POST /api/oauth/token <https://test.openlmis.org/auth/docs/#!/default/post_api_oauth_token>`_
2. click on :code:`Authorize` in the top right of the page
3. in the box that has popped-up, enter username :code:`user-client` and password :code:`changeme`
4. click :code:`Authorize` under :code:`password`
5. enter the username :code:`administrator` and password :code:`password`
6. click :code:`Try it out!`
7. In the :code:`Response body` box, copy the UUID.  e.g. :code:`"access_token": "a93bcab7-aaf5-43fe-9301-76c526698898"` copy :code:`a93bcab7-aaf5-43fe-9301-76c526698898` to use later.
8. Paste the UUID you just copied into any endpoint's :code:`access_token` field.

****
Auth
****

Security credentials, Authentication and Authorization. Uses OAuth2.

- `Auth Service <authService.html>`_
- `Auth Service Design <authServiceDesign.html>`_
- `Auth UI <authUI.html>`_
- `Auth ERD <erd-auth.html>`_
- `Live Documentation for Auth API <http://test.openlmis.org/auth/docs/#/default>`_
- `Static Documentation for Auth API <http://build.openlmis.org/job/OpenLMIS-auth-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

*******************
Fulfillment Service
*******************

Placing orders at warehouses, fulfilling those orders (ERP or Pick Pack Ship) and proof of
deliveries.

- `Fulfillment Service <fulfillmentService.html>`_
- `Fulfillment UI <fulfillmentUI.html>`_
- `Fulfillment ERD <erd-fulfillment.html>`_
- `Live Documentation for Fulfillment API <http://test.openlmis.org/fulfillment/docs/#/default>`_
- `Static Documentation for Fulfillment API <http://build.openlmis.org/job/OpenLMIS-fulfillment-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

*******************
CCE Service
*******************

Cold Chain Equipment:  Catalog (PQS oriented), Inventory (equipment at locations) and functional
status.

- `CCE Service <cceService.html>`_
- `CCE ERD <erd-cce.html>`_
- `Live Documentation for CCE API <http://test.openlmis.org/cce/docs/#/default>`_
- `Static Documentation for CCE API <http://build.openlmis.org/job/OpenLMIS-cce-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

*******************
Report Service
*******************

Printed / banded reports.  Owns report storage, generation, and seeding rights that users may be
given.

- `Report Service <reportService.html>`_
- `Report ERD <erd-report.html>`_
- `Live Documentation for Report API <http://test.openlmis.org/report/docs/#/default>`_
- `Static Documentation for Report API <http://build.openlmis.org/job/OpenLMIS-report-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

********************
Notification Service
********************

Notifying users when their attention is needed.

- `Live Documentation for Notification API <http://test.openlmis.org/notification/docs/#/default>`_
- `Static Documentation for Notification API <http://build.openlmis.org/job/OpenLMIS-notification-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

**********************
Reference Data Service
**********************

Reference (meta) data for: users, facilities, programs, products, schedules, etc.

- `Reference Data Service <referencedataService.html>`_
- `Reference Data UI <referencedataUI.html>`_
- `Reference Data ERD <erd-referencedata.html>`_
- `Live Documentation for Reference Data API <http://test.openlmis.org/referencedata/docs/#/default>`_
- `Static Documentation for Reference Data API <http://build.openlmis.org/job/OpenLMIS-referencedata-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

************
Reference UI
************
The Reference-UI is a single page application that communicates with OpenLMIS Services to provide a user interface for interacting with OpenLMIS. This UI aims to be modular, extendable, and provide a consistent user experience.

At a high level, the OpenLMIS-UI uses Javascript to create an application that runs in a user's web browser. After the OpenLMIS-UI has been loaded into a user's web browser, The OpenLMIS-UI is designed to be used while offline. Supported web browsers are Google Chrome and Firefox.

The OpenLMIS-UI is state driven, meaning the browser's URL determines what is displayed on the screen. Once the application starts, the browser's current URL is parsed and used to retrive data from OpenLMIS Services. All retrived data populates HTML-based views, which are displayed in the user's browser and styled by CSS.

The primary libraries that are used by the OpenLMIS-UI are:

- `Grunt <https://gruntjs.com/>`_ orchestrates the application build process
- `AppCache <https://developer.mozilla.org/en-US/docs/Web/HTML/Using_the_application_cache>`_ allows the application run in a browser while offline
- `AngularJS v1 <https://angularjs.org/>`_ is the application framework
- `Angular UI-Router <https://github.com/angular-ui/ui-router/>`_ provides URL routing
- `PouchDB <https://pouchdb.com/>`_ stores data for offline functionality
- `Sass <http://sass-lang.com/>`_ is used to generate CSS

More about the Reference-UI:

- `Reference UI <referenceUI.html>`_
- `UI Styleguide <http://build.openlmis.org/job/OpenLMIS-reference-ui/lastSuccessfulBuild/artifact/build/styleguide/index.html>`_
- `Javascript Documentation <http://build.openlmis.org/job/OpenLMIS-reference-ui/lastSuccessfulBuild/artifact/build/docs/index.html#/api>`_
- `UI Layout <uiLayout.html>`_
- `UI Components <uiComponents.html>`_
- `Dev UI <devUI.html>`_

*******************
Requisition Service
*******************

Requisitions (pull-based), Requisition Templates for requesting more stock on a schedule through
an administrative hierarchy.

- `Requisition Service <requisitionService.html>`_
- `Requisition UI <requisitionUI.html>`_
- `Requisition ERD <erd-requisition.html>`_
- `Live Documentation for Requisition API <http://test.openlmis.org/requisition/docs/#/default>`_
- `Static Documentation for Requisition API <http://build.openlmis.org/job/OpenLMIS-requisition-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

*************************
Stock Management Service
*************************

Electronic stock cards and stock transactions.

- `Stock Management Service <stockmanagementService.html>`_
- `Stock Management UI <stockmanagementUI.html>`_
- `Stock Management ERD <erd-stockmanagement.html>`_
- `Live Documentation for Stock Management API <http://test.openlmis.org/stockmanagement/docs/#/default>`_
- `Static Documentation for Stock Management API <http://build.openlmis.org/job/OpenLMIS-stockmanagement-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_
