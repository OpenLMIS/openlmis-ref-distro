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
- `Auth UI <authUI.html>`_
- `Auth ERD <erd-auth.html>`_
- `Static Documentation for Auth API <http://build.openlmis.org/job/OpenLMIS-auth-service/275/artifact/build/resources/main/api-definition.html>`_

*******************
Fulfillment Service
*******************

Includes the basics of fulfillment.

- `Fulfillment Service <fulfillmentService.html>`_
- `Fulfillment UI <fulfillmentUI.html>`_
- `Fulfillment ERD <erd-fulfillment.html>`_
- `Live Documentation for Fulfillment API <http://test.openlmis.org/fulfillment/docs/#/default>`_
- `Static Documentation for Fulfillment API <http://build.openlmis.org/job/OpenLMIS-fulfillment-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

*******************
CCE Service
*******************

Allows managing Cold Chain Equipment.

- `CCE Service <cceService.html>`_
- `CCE ERD <cce-fulfillment.html>`_
- `Live Documentation for CCE API <http://test.openlmis.org/cce/docs/#/default>`_
- `Static Documentation for CCE API <http://build.openlmis.org/job/OpenLMIS-cce-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

*******************
Report Service
*******************

Allows managing reports.

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

Provides the reference data for the rest of the processes: facilities, programs, products, etc.

- `Reference Data Service <referencedataService.html>`_
- `Reference Data UI <referencedataUI.html>`_
- `Reference Data ERD <erd-referencedata.html>`_
- `Live Documentation for Reference Data API <http://test.openlmis.org/referencedata/docs/#/default>`_
- `Static Documentation for Reference Data API <http://build.openlmis.org/job/OpenLMIS-referencedata-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

************
Reference UI
************

The Reference UI compiles together all the assets that make up the OpenLMIS-UI. See the `build process documentation <../architecture/buildProcess.html>`_ to understand exactly how the UI is compiled.

- `UI Styleguide <http://build.openlmis.org/job/OpenLMIS-reference-ui/lastSuccessfulBuild/artifact/build/styleguide/index.html#!/login>`_
- `Javascript Documentation <http://build.openlmis.org/job/OpenLMIS-reference-ui/lastSuccessfulBuild/artifact/build/docs/index.html#/api>`_
- `Reference UI <referenceUI.html>`_
- `UI Layout <uiLayout.html>`_
- `UI Components <uiComponents.html>`_
- `Dev UI <devUI.html>`_

*******************
Requisition Service
*******************

Requisition (pull) based replenishment process.

- `Requisition Service <requisitionService.html>`_
- `Requisition UI <requisitionUI.html>`_
- `Requisition ERD <erd-requisition.html>`_
- `Live Documentation for Requisition API <http://test.openlmis.org/requisition/docs/#/default>`_
- `Static Documentation for Requisition API <http://build.openlmis.org/job/OpenLMIS-requisition-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_

*************************
Stock Management Service
*************************

Electronic stock cards.

- `Stock Management Service <stockmanagementService.html>`_
- `Stock Management UI <stockmanagementUI.html>`_
- `Stock Management ERD <erd-stockmanagement.html>`_
- `Live Documentation for Stock Management API <http://test.openlmis.org/stockmanagement/docs/#/default>`_
- `Static Documentation for Stock Management API <http://build.openlmis.org/job/OpenLMIS-stockmanagement-service/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html>`_
