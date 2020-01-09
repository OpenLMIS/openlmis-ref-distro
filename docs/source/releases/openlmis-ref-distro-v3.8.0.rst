====================================
3.8.0 Release Notes - December 19, 2019
====================================

Status: Stable
===============

3.8.0 is a stable release, and all users of `OpenLMIS version 3
<https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017>`_ are
encouraged to adopt it.

Release Notes
=============
The OpenLMIS Community is excited to announce the **3.8.0 release** of OpenLMIS! It is another major milestone in the version 3 `re-architecture <https://openlmis.atlassian.net/wiki/display/OP/Re-Architecture>`_ that allows more functionality to be shared among the community of OpenLMIS implementers.

For a full list of features and bug-fixes since 3.7.0, see `OpenLMIS 3.8.0 Jira tickets
<https://openlmis.atlassian.net/issues/?jql=status%3DDone%20AND%20project%3DOLMIS%20AND%20fixVersion%3D3.8%20and%20type!%3DTest%20and%20type!%3DEpic%20ORDER%20BY%20%22Epic%20Link%22%20asc%2C%20key%20ASC>`_.

For information about future planned releases, see the `Living Product Roadmap
<https://openlmis.atlassian.net/wiki/display/OP/Living+Product+Roadmap>`_. Pull requests and
`contributions <http://docs.openlmis.org/en/latest/contribute/contributionGuide.html>`_ are welcome.

Compatibility
-------------

Unless noted here, all other changes to OpenLMIS 3.x are backwards-compatible. All changes to data
or schemas include automated migrations from previous versions back to version 3.0.1. All new or
altered functionality is listed in the sections below for New Features and Changes to Existing
Functionality.

Upgrading from Older Versions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you are upgrading to OpenLMIS 3.8.0 from OpenLMIS 3.0.x or 3.1.x (without first upgrading to
3.2.x), please review the `3.2.0
Release Notes <http://docs.openlmis.org/en/latest/releases/openlmis-ref-distro-v3.2.0.html>`_ for
important compatibility information about a required PostgreSQL extension and data migrations.

For information about upgrade paths from OpenLMIS 1 and 2 to version 3, see the `3.0.0 Release
Notes <https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017>`_.

Download or View on GitHub
--------------------------

`OpenLMIS Reference Distribution 3.8.0
<https://github.com/OpenLMIS/openlmis-ref-distro/releases/tag/v3.8.0>`_

Known Bugs
==========

Bug reports are collected in Jira for troubleshooting, analysis and resolution on an ongoing basis. See `OpenLMIS 3.8.0
Bugs <https://openlmis.atlassian.net/issues/?jql=project%20%3D%20OLMIS%20AND%20issuetype%20%3D%20Bug%20AND%20affectedVersion%20%3D%203.8%20order%20by%20priority%20DESC%2C%20status%20ASC%2C%20key%20ASC>`_ for the current list of known bugs.

To report a bug, see `Reporting Bugs
<http://docs.openlmis.org/en/latest/contribute/contributionGuide.html#reporting-bugs>`_.

New Features
============
The OpenLMIS community proudly presents the following new features with 3.8.0:

- **Performance Improvements** This release addresses some of the performance regressions from the version 3.7.0 release. Specifically, it avoids n+1 issues when loading Orderables, improved updating requisitions, and reduced the loading of FTAPS.
- **Configuration Improvements** Administrators can now quickly assign user roles based on another user, rather than having to manually recreate all the role assignments. This specific feature is one of many that will be worked on in future releases as we continue to simplify the overall system configuration.

Reference the `3.8 epics <https://openlmis.atlassian.net/issues/?filter=20614&jql=issuetype%20%3D%20Epic%20AND%20status%20in%20(Done%2C%20%22In%20Progress%22)%20AND%20fixVersion%20%3D%203.8%20ORDER%20BY%20created%20DESC>`_ for more details.

Changes to Existing Functionality
=================================

See `all 3.8 issues tagged 'UIChange' in Jira <https://openlmis.atlassian.net/issues/?jql=status%3DDone%20AND%20project%3DOLMIS%20AND%20fixVersion%3D3.8%20and%20type!%3DTest%20and%20type!%3DEpic%20and%20labels%20IN%20(UIChange)%20ORDER%20BY%20type%20ASC%2C%20priority%20DESC%2C%20key%20ASC>`_.

API Changes
===========

API changes can be found in each service CHANGELOG.md file, found in the root directory of the service repository.

Performance
========================

The performance of version 3.8.0 is overall an improvement from version 3.7.0 and starts to address the performance regressions that came with that release.

OpenLMIS conducted manual performance tests of the same user workflows with the same test data we used in testing v3.2.1 to establish that last-mile performance characteristics have been retained at a minimum. For details on the test results and process, please see `this wiki page <https://openlmis.atlassian.net/wiki/spaces/OP/pages/116949318/Performance+Metrics>`_.

The following chart displays the UI loading times in seconds for 3.5, 3.6, 3.7, and 3.8 using the same test data.

.. image:: UI-Performance-3.8.png
    :alt: UI Load Times for 3.5 through 3.8

Test Coverage
=============

OpenLMIS 3.8.0 was tested using the established OpenLMIS Release Candidate process.  As part of this process, full manual test cycles were executed for each release candidate published. Any critical or blocker bugs found during the release candidate were resolved in a bug fix cycle with a full manual test cycle executed before releasing the final version 3.8.0. Manual tests were conducted using a set of 99 Zephyr tests tracked in Jira and 7 manual tests for reporting. Only a single non-critical bug was found during testing! For more details about test executions and bugs found for this release please see `the 3.8 QA Release and Bug Triage wiki page <https://openlmis.atlassian.net/wiki/spaces/OP/pages/590577712/3.8+QA+Release+Bug+Triage+status>`_.

All Changes by Component
========================

Version 3.8.0 of the Reference Distribution contains updated versions of the components listed
below. The Reference Distribution bundles these component together using Docker to create a complete
OpenLMIS instance. Each component has its own own public GitHub repository (source code) and
DockerHub repository (release image). The Reference Distribution and components are versioned
independently; for details see `Versioning and Releasing
<http://docs.openlmis.org/en/latest/conventions/versioningReleasing.html>`_.

Auth Service 4.2.0
------------------

`Auth CHANGELOG <https://github.com/OpenLMIS/openlmis-auth/blob/master/CHANGELOG.md>`_

CCE Service 1.1.0
-----------------

`CCE CHANGELOG <https://github.com/OpenLMIS/openlmis-cce/blob/master/CHANGELOG.md>`_

Fulfillment Service 8.1.0
-------------------------

`Fulfillment CHANGELOG <https://github.com/OpenLMIS/openlmis-fulfillment/blob/master/CHANGELOG.md>`_

Notification Service 4.2.0
--------------------------

`Notification CHANGELOG <https://github.com/OpenLMIS/openlmis-notification/blob/master/CHANGELOG.md>`_

Reference Data Service 15.0.0
-----------------------------

`ReferenceData CHANGELOG <https://github.com/OpenLMIS/openlmis-referencedata/blob/master/CHANGELOG.md>`_

Report Service 1.1.4
--------------------

This service is intended to provide reporting functionality for other components to use. Built-in
reports in OpenLMIS 3.4.0 are still powered by their own services. In future releases, they may be
migrated to a new version of this centralized report service.

**Warning**: Developers should take note that the design of this service will be changing with
future releases. Developers and implementers are discouraged from using this 1.1.1 version to build
additional reports.

`Report CHANGELOG <https://github.com/OpenLMIS/openlmis-report/blob/master/CHANGELOG.md>`_

Requisition Service 8.2.1
-------------------------

`Requisition CHANGELOG <https://github.com/OpenLMIS/openlmis-requisition/blob/master/CHANGELOG.md>`_

Stock Management 5.0.1
----------------------

`Stock Management CHANGELOG <https://github.com/OpenLMIS/openlmis-stockmanagement/blob/master/CHANGELOG.md>`_

Reference UI 5.1.6
------------------

`The Reference UI <https://github.com/OpenLMIS/openlmis-reference-ui/>`_
is the web-based user interface for the OpenLMIS Reference Distribution. This user interface is
a single page web application that is optimized for offline and low-bandwidth environments.
The Reference UI is compiled together from module UI modules using Docker compose along with the
OpenLMIS dev-ui. UI modules included in the Reference UI are:

Reference Data-UI 5.6.1
~~~~~~~~~~~~~~~~~~~~~~~

`ReferenceData-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-referencedata-ui/blob/master/CHANGELOG.md>`_

Auth-UI 6.2.2
~~~~~~~~~~~~~

`Auth-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-auth-ui/blob/master/CHANGELOG.md>`_

CCE-UI 1.0.5
~~~~~~~~~~~~

`CCE-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-cce-ui/blob/master/CHANGELOG.md>`_

Fulfillment-UI 6.0.5
~~~~~~~~~~~~~~~~~~~~

`Fulfillment-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-fulfillment-ui/blob/master/CHANGELOG.md>`_

Report-UI 5.2.2
~~~~~~~~~~~~~~~

`Report-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-report-ui/blob/master/CHANGELOG.md>`_

Requisition-UI 7.0.1
~~~~~~~~~~~~~~~~~~~~

`Requisition-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-requisition-ui/blob/master/CHANGELOG.md>`_

Stock Management-UI 2.0.5
~~~~~~~~~~~~~~~~~~~~~~~~~

`Stock Management-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-stockmanagement-ui/blob/master/CHANGELOG.md>`_

UI-Components 7.2.1
~~~~~~~~~~~~~~~~~~~

`UI-Components CHANGELOG <https://github.com/OpenLMIS/openlmis-ui-components/blob/master/CHANGELOG.md>`_

UI-Layout 5.1.5
~~~~~~~~~~~~~~~

`UI-Layout CHANGELOG <https://github.com/OpenLMIS/openlmis-ui-layout/blob/master/CHANGELOG.md>`_

Dev UI 9.0.1
~~~~~~~~~~~~

The `Dev-UI CHANGLOG <https://github.com/OpenLMIS/dev-ui/blob/master/CHANGELOG.md>`_

Components with No Changes
==========================

The components that have not changed are:

- `Service Util <https://github.com/OpenLMIS/openlmis-service-util>`_
- `Logging Service <https://github.com/OpenLMIS/openlmis-rsyslog>`_
- Consul-friendly distribution of `nginx <https://github.com/OpenLMIS/openlmis-nginx>`_
- Docker `Postgres 9.6-postgis image <https://github.com/OpenLMIS/postgres>`_
- Docker `scalyr image <https://github.com/OpenLMIS/openlmis-scalyr>`_

Contributions
=============

Many organizations and individuals around the world have contributed to OpenLMIS version 3 by
serving on our committees (Governance, Product and Technical), requesting improvements, suggesting
features and writing code and documentation. Please visit our GitHub repos to see the list of
individual contributors on the OpenLMIS codebase. If anyone who contributed in GitHub is missing,
please contact the Community Manager.

Thanks to the Malawi implementation team who has continued to contribute a number of changes
that have global shared benefit.

Further Resources
=================

Please see the Implementer Toolkit on the `OpenLMIS website <http://openlmis.org/get-started/implementer-toolkit/>`_ to learn more about best practicies in implementing OpenLMIS.  Also, learn more about the `OpenLMIS Community <http://openlmis.org/about/community/>`_ and how to get involved!
