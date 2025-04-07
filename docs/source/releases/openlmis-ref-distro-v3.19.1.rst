=====================================
3.19.1 Release Notes - April 07, 2025
=====================================

Status: Stable
===============

3.19.1 is a stable release, and all users of `OpenLMIS version 3
<https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017>`_ are
encouraged to adopt it.

Release Notes
=============
The OpenLMIS Community is excited to announce the **3.19.1 release** of OpenLMIS! It is another major milestone in the version 3 `re-architecture <https://openlmis.atlassian.net/wiki/display/OP/Re-Architecture>`_ that allows more functionality to be shared among the community of OpenLMIS implementers.

For a full list of features and bug-fixes of 3.19.0 and 3.19.1, see `OpenLMIS 3.19.0 Jira tickets
<https://openlmis.atlassian.net/issues/OLMIS-7999?jql=project%20%3D%20OLMIS%20AND%20text%20~%20%223.19_Release%22%20AND%20type%20%3D%20Epic%20ORDER%20BY%20%22Epic%20Link%22%20ASC%2C%20key%20ASC>`_.

Compatibility
-------------

**Important Notice** for Implementers Using a Custom Reports Service Forked from Core:
If you are using a forked version of the core reports service, please ensure that your implementation is updated to incorporate the latest changes required for Dashboard reports in version 3.19.1

Refer to the following repository for the necessary updates:
OpenLMIS Reports - `<https://github.com/OpenLMIS/openlmis-report/tree/rel-1.4.0-hotfix>`_

All other changes to OpenLMIS 3.x are backwards-compatible. All changes to data
or schemas include automated migrations from previous versions back to version 3.0.1. All new or
altered functionality is listed in the sections below for New Features and Changes to Existing
Functionality.

Upgrading from Older Versions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you are upgrading from OpenLMIS 3.0.x or 3.1.x (without first upgrading to 3.2.x), please review the `3.2.0
Release Notes <http://docs.openlmis.org/en/latest/releases/openlmis-ref-distro-v3.2.0.html>`_ for
important compatibility information about a required PostgreSQL extension and data migrations.

For information about upgrade paths from OpenLMIS 1 and 2 to version 3, see the `3.0.0 Release
Notes <https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017>`_.

If you are upgrading to version 3.19.1 THE SUPERSET reports will need to be added manually by system administrators.
Short manual can be found here: `<https://github.com/OpenLMIS/openlmis-report/blob/rel-1.4.0-hotfix/CHANGELOG.md#140-hotfix--2025-04-04>`_

Download or View on GitHub
--------------------------

`OpenLMIS Reference Distribution 3.19.1
<https://github.com/OpenLMIS/openlmis-ref-distro/releases/tag/v3.19.1>`_

Known Bugs
==========

Bug reports are collected in Jira for troubleshooting, analysis and resolution on an ongoing basis. See `OpenLMIS 3.19.1
Bugs <https://openlmis.atlassian.net/issues/?jql=type%20%3D%20Bug%20and%20project%20%3D%20%22OpenLMIS%20General%22%20AND%20status%20not%20in%20(Done%2CCanceled)&startIndex=200>`_ for the current list of known bugs.

To report a bug, see `Reporting Bugs
<http://docs.openlmis.org/en/latest/contribute/contributionGuide.html#reporting-bugs>`_.

Bug fixes since 3.19.0
======================

- Fixed issue with failing migrations.

New Features
============

- **Dashboard Reports Functionality**: Allows managing SUPERSET or PowerBI reports via UI.
- **User Import/Export Functionality**: Enables to import and export users.
- **Catchment Population Management**: Includes import/export functionality for managing population data.
- **New Stock Status Reports**:
    - Report showing stock status at a specific point in time.
    - Report showing stock status over a specified time range.

Changes to Existing Functionality
=================================

- **Requisition Improvements**:
    - Added missing fields to requisition prints.
    - Corrected Stock Out Days from 29 to 30.
    - Fixed incorrect period names for emergency requisition.
- **Administration & Configuration Fixes**:
    - Fixed issue where user was created with an incorrect email.
    - Added missing filter on Requisition Groups > Edit page.
    - Resolved Null Pointer Exception (NPE) when adding programs to products.
- **Fulfillment & Proof of Delivery Enhancements**:
    - Proof of Delivery Manage Action page optimized to load only relevant Orderables.
    - Fixed issue where it was not possible to manage both fulfillment and PoD.
- **Stock Management Enhancements**:
    - Improved filtering by geographic zone for better performance.
    - Introduced new public API endpoints for stock card summaries and stock events.

API Changes
===========

- API changes can be found in each service CHANGELOG.md file, found in the root directory of the service repository.

Performance
===========

- Improved filtering functionalities.
- Upgraded dependencies.

Test Coverage
=============

OpenLMIS 3.19.1 was tested using the established OpenLMIS Release Candidate process. As part of this process, full manual test cycles were executed for each release candidate published. Any critical or blocker bugs found during the release candidate were resolved in a bug fix cycle with a full manual test cycle executed before releasing the final version 3.19.1. Manual tests were conducted using a set of 125 QAlity tests tracked in Jira. For more details about test executions and bugs found for this release please see `the 3.19 QA Release and Bug Triage wiki page <https://openlmis.atlassian.net/wiki/spaces/OP/pages/3027566594/The+3.19+Regression+and+Release+Candidate+Test+Plan>`_.

All Changes by Component
========================

Version 3.19.1 of the Reference Distribution contains updated versions of the components listed
below. The Reference Distribution bundles these component together using Docker to create a complete
OpenLMIS instance. Each component has its own own public GitHub repository (source code) and
DockerHub repository (release image). The Reference Distribution and components are versioned
independently; for details see `Versioning and Releasing
<http://docs.openlmis.org/en/latest/conventions/versioningReleasing.html>`_.

Reference Data Service 15.3.0-hotfix
-----------------------------

`ReferenceData CHANGELOG <https://github.com/OpenLMIS/openlmis-referencedata/blob/rel-15.3.0-hotfix/CHANGELOG.md>`_

Report Service 1.4.0-hotfix
--------------------

This service is intended to provide reporting functionality for other components to use. Built-in
reports in OpenLMIS 3.4.0 are still powered by their own services. In future releases, they may be
migrated to a new version of this centralized report service.

**Warning**: Developers should take note that the design of this service will be changing with
future releases. Developers and implementers are discouraged from using this 1.4.x version to build
additional reports.

`Report CHANGELOG <https://github.com/OpenLMIS/openlmis-report/blob/rel-1.4.0-hotfix/CHANGELOG.md>`_

Components with No Changes
==========================

Auth Service 4.3.5
------------------

`Auth CHANGELOG <https://github.com/OpenLMIS/openlmis-auth/blob/rel-4.3.5/CHANGELOG.md>`_

CCE Service 1.3.5
-----------------

`CCE CHANGELOG <https://github.com/OpenLMIS/openlmis-cce/blob/rel-1.3.5/CHANGELOG.md>`_

Fulfillment Service 9.2.0
-------------------------

`Fulfillment CHANGELOG <https://github.com/OpenLMIS/openlmis-fulfillment/blob/rel-9.2.0/CHANGELOG.md>`_

Notification Service 4.3.5
--------------------------

`Notification CHANGELOG <https://github.com/OpenLMIS/openlmis-notification/blob/rel-4.3.5/CHANGELOG.md>`_

Requisition Service 8.4.0
-------------------------

`Requisition CHANGELOG <https://github.com/OpenLMIS/openlmis-requisition/blob/rel-8.4.0/CHANGELOG.md>`_

Stock Management 5.2.0
----------------------

`Stock Management CHANGELOG <https://github.com/OpenLMIS/openlmis-stockmanagement/blob/rel-5.2.0/CHANGELOG.md>`_

Hapifhir 2.0.4
----------------------

`Hapifhir CHANGELOG <https://github.com/OpenLMIS/openlmis-hapifhir/blob/rel-2.0.4/CHANGELOG.md>`_

Diagnostics 1.1.4
----------------------

`Diagnostics CHANGELOG <https://github.com/OpenLMIS/openlmis-diagnostics/blob/rel-1.1.4/CHANGELOG.md>`_

BUQ 1.0.2
----------------------

`BUQ CHANGELOG <https://github.com/OpenLMIS/openlmis-buq/blob/rel-1.0.2/CHANGELOG.md>`_

Dhis2 Integration 1.0.1
----------------------

`Dhis2 Integration CHANGELOG <https://github.com/OpenLMIS/openlmis-dhis2-integration/blob/rel-1.0.1/CHANGELOG.md>`_


Reference UI 5.2.11
------------------

`The Reference UI <https://github.com/OpenLMIS/openlmis-reference-ui/tree/rel-5.2.11>`_
is the web-based user interface for the OpenLMIS Reference Distribution. This user interface is
a single page web application that is optimized for offline and low-bandwidth environments.
The Reference UI is compiled together from module UI modules using Docker compose along with the
OpenLMIS dev-ui. UI modules included in the Reference UI are:

Reference Data-UI 5.6.16
~~~~~~~~~~~~~~~~~~~~~~~

`ReferenceData-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-referencedata-ui/blob/rel-5.6.16/CHANGELOG.md>`_

Auth-UI 6.2.15
~~~~~~~~~~~~~

`Auth-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-auth-ui/blob/rel-6.2.15/CHANGELOG.md>`_

CCE-UI 1.1.7
~~~~~~~~~~~~

`CCE-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-cce-ui/blob/rel-1.1.7/CHANGELOG.md>`_

Fulfillment-UI 6.1.6
~~~~~~~~~~~~~~~~~~~~

`Fulfillment-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-fulfillment-ui/blob/rel-6.1.6/CHANGELOG.md>`_

Report-UI 5.2.14
~~~~~~~~~~~~~~~

`Report-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-report-ui/blob/rel-5.2.14/CHANGELOG.md>`_

Requisition-UI 7.0.14
~~~~~~~~~~~~~~~~~~~~

`Requisition-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-requisition-ui/blob/rel-7.0.14/CHANGELOG.md>`_

Stock Management-UI 2.1.8
~~~~~~~~~~~~~~~~~~~~~~~~~

`Stock Management-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-stockmanagement-ui/blob/rel-2.1.8/CHANGELOG.md>`_

UI-Components 7.2.13
~~~~~~~~~~~~~~~~~~~

`UI-Components CHANGELOG <https://github.com/OpenLMIS/openlmis-ui-components/blob/rel-7.2.13/CHANGELOG.md>`_

UI-Layout 5.2.8
~~~~~~~~~~~~~~~

`UI-Layout CHANGELOG <https://github.com/OpenLMIS/openlmis-ui-layout/blob/rel-5.2.8/CHANGELOG.md>`_

Dev UI 9.0.7
~~~~~~~~~~~~

The `Dev-UI CHANGLOG <https://github.com/OpenLMIS/dev-ui/blob/rel-9.0.7/CHANGELOG.md>`_

Others
~~~~~~~~~~~~
`Service Util <https://github.com/OpenLMIS/openlmis-service-util>`_
`Logging Service <https://github.com/OpenLMIS/openlmis-rsyslog>`_
Consul-friendly distribution of `nginx <https://github.com/OpenLMIS/openlmis-nginx>`_
Docker `Postgres 9.6-postgis image <https://github.com/OpenLMIS/postgres>`_
Docker `scalyr image <https://github.com/OpenLMIS/openlmis-scalyr>`_

Contributions
=============

Many organizations and individuals around the world have contributed to OpenLMIS version 3 by
serving on our committees (Governance, Product and Technical), requesting improvements, suggesting
features and writing code and documentation. Please visit our GitHub repos to see the list of
individual contributors on the OpenLMIS codebase. If anyone who contributed in GitHub is missing,
please contact the Community Manager.

Further Resources
=================

Please see the Implementer Toolkit on the `OpenLMIS website <http://openlmis.org/get-started/implementer-toolkit/>`_ to learn more about best practices in implementing OpenLMIS. Also, learn more about the `OpenLMIS Community <http://openlmis.org/about/community/>`_ and how to get involved!
