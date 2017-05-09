=================
API documentation
=================

***************************************
Logging in with the Live Documentation
***************************************

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

************
Auth Service
************

Security credentials, Authentication and Authorization. Uses OAuth2.

`Static Documentation for Auth API <http://build.openlmis.org/job/OpenLMIS-auth-service/229/artifact/build/resources/main/api-definition.html>`_

**********************
Reference Data Service
**********************

Provides the reference data for the rest of the processes: facilities, programs, products, etc.

`Static Documentation for Reference Data API <http://build.openlmis.org/job/OpenLMIS-referencedata-service/705/artifact/build/resources/main/api-definition.html>`_

*******************
Requisition Service
*******************

Requisition (pull) based replenishment process.

`Static Documentation for Requisition API <http://build.openlmis.org/job/OpenLMIS-requisition-service/1463/artifact/build/resources/main/api-definition.html>`_

*******************
Fulfillment Service
*******************

Includes the basics of fulfillment.

`Static Documentation for Fulfillment API <http://build.openlmis.org/job/OpenLMIS-fulfillment-service/263/artifact/build/resources/main/api-definition.html>`_

********************
Notification Service
********************

Notifying users when their attention is needed.

`Static Documentation for Notification API <http://build.openlmis.org/job/OpenLMIS-notification-service/101/artifact/build/resources/main/api-definition.html>`_
