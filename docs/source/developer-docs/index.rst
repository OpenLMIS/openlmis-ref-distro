==============
Developer docs
==============

As of OpenLMIS v3, the `architecture <https://openlmis.atlassian.net/wiki/x/IYAKAw>`_
has transitioned to (micro) services fulfilling RESTful (HTTP) API requests 
from a modularized Reference UI.  Extension mechanisms in addition to 
microservices and UI modules further allow for components of the architecture 
to be customized without the need for the community to fork the code base:

- Extension Points & Modules - allows Service functionality to be modified
- Extra Data - allows for extensions to store data with existing components

Combined these components allow the OpenLMIS community to customize and
contribute to a shared LMIS.

Conventions
===========

.. toctree::
   :maxdepth: 1
   
   codeStyleguide
   testing
   errorHandling
   licenseHeader

Component Readme's
=================

.. toctree::
   :maxdepth: 1

   requisition
   fulfillment
   auth
   referencedata
   stockmanagement
   templateService
   requisitionUI

Contribute to these docs
========================

.. toctree::
   :maxdepth: 1
   
   contributeDocs
