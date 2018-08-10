========================================
3.3.1 Patch Release Notes - 17 July 2018
========================================

Status: Stable with disclaimer
==============================

3.3.1 Patch release is recommended for users of OpenLMIS version 3.3.0 because the patch inclues a bug fix for requisition statuses when saved concurrently. 
Disclaimer: The 3.3.1 Patch release does not contain any known blocking bugs. Full regression testing and manual performance testing was not conducted as part of the patch release. 

Patch Release Notes
===================
3.3.1 Patch Release contains the bug fix for - `OLMIS-4728 <https://openlmis.atlassian.net/browse/OLMIS-4728>`_.

For information about future planned releases, see the `Living Product Roadmap
<https://openlmis.atlassian.net/wiki/display/OP/Living+Product+Roadmap>`_. Pull requests and
`contributions <http://docs.openlmis.org/en/latest/contribute/contributionGuide.html>`_ are welcome.

Compatibility
-------------

Compatible with OpenLMIS 3.3.0

Backwards-Compatible Except As Noted
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Unless noted here, all other changes to OpenLMIS 3.x are backwards-compatible. All changes to data
or schemas include automated migrations from previous versions back to version 3.0.1. All new or
altered functionality is listed in the sections below for New Features and Changes to Existing
Functionality.

Upgrading from Older Versions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you are upgrading to OpenLMIS 3.3.0 from OpenLMIS 3.0.x or 3.1.x (without first upgrading to
3.2.x), please review the `3.2.0
Release Notes <http://docs.openlmis.org/en/latest/releases/openlmis-ref-distro-v3.2.0.html>`_ for
important compatibility information about a required PostgreSQL extension and data migrations.

For information about upgrade paths from OpenLMIS 1 and 2 to version 3, see the `3.0.0 Release
Notes <https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017>`_.

Download or View on GitHub
--------------------------

`OpenLMIS Reference Distribution 3.3.1
<https://github.com/OpenLMIS/openlmis-ref-distro/releases/tag/v3.3.1>`_

Known Bugs
==========

No known additional bugs were included in this patch release.
Bug reports are collected in Jira for troubleshooting, analysis and resolution on an ongoing basis. See `OpenLMIS 3.3.0
Bugs <https://openlmis.atlassian.net/issues/?jql=project%3DOLMIS%20and%20type%3DBug%20and%20affectedVersion%3D3.3%20order%20by%20priority%20DESC%2C%20status%20ASC%2C%20key%20ASC>`_ for the current list of known bugs.

To report a bug, see `Reporting Bugs
<http://docs.openlmis.org/en/latest/contribute/contributionGuide.html#reporting-bugs>`_.

New Features
============

No new features were introduced with this patch release.

Changes to Existing Functionality
=================================

Version 3.3.1 contains changes that impact users of existing functionality. Please review these
changes which may require informing end-users and/or updating your customizations/extensions:

- `OLMIS-4728 <https://openlmis.atlassian.net/browse/OLMIS-4728>`_: Requisition's properties can be overwritten when saved concurrently.

Performance 
===========

No manual performance testing was conducted for this patch release.

Test Coverage
=============

Manual regression tests were conducted using a set of 30 Zephyr tests tracked in Jira. One bug was
found and resolved during testing. 
See the test cycle for all regression test case executions for this patch release: `3.3.1 Patch Release Test Plan and Execution
<https://openlmis.atlassian.net/wiki/spaces/OP/pages/413991014/Patch+Release+Test+Plan+v3.3.1>`_.

Component Version Numbers
=========================

Version 3.3.1 of the Reference Distribution contains the following components and versions listed
below. The Reference Distribution bundles these components together using Docker to create a complete
OpenLMIS instance. Each component has its own own public GitHub repository (source code) and
DockerHub repository (release image). The Reference Distribution and components are versioned
independently; for details see `Versioning and Releasing
<http://docs.openlmis.org/en/latest/conventions/versioningReleasing.html>`_.

Auth Service 3.2.0
------------------

CCE Service 1.0.0
-----------------

Fulfillment Service 7.0.0
-------------------------

Notification Service 3.0.5
--------------------------

Reference Data Service 10.0.0
-----------------------------

Reference UI 5.0.7
------------------

The Reference UI (`https://github.com/OpenLMIS/openlmis-reference-ui/ <https://github.com/OpenLMIS/openlmis-reference-ui/>`_)
is the web-based user interface for the OpenLMIS Reference Distribution. This user interface is
a single page web application that is optimized for offline and low-bandwidth environments.
The Reference UI is compiled together from module UI modules using Docker compose along with the
OpenLMIS dev-ui. UI modules included in the Reference UI are:

auth-ui 6.1.0
~~~~~~~~~~~~~

cce-ui 1.0.0
~~~~~~~~~~~~

fulfillment-ui 6.0.0
~~~~~~~~~~~~~~~~~~~~

referencedata-ui 5.3.0
~~~~~~~~~~~~~~~~~~~~~~

report-ui 5.0.5
~~~~~~~~~~~~~~~

requisition-ui 6.1.0
~~~~~~~~~~~~~~~~~~~~

stockmanagement-ui 1.1.0
~~~~~~~~~~~~~~~~~~~~~~~~

ui-components 5.3.0
~~~~~~~~~~~~~~~~~~~

ui-layout 5.1.0
~~~~~~~~~~~~~~~

Dev UI v7
~~~~~~~~~

Report Service 1.0.1
--------------------

This service is intended to provide reporting functionality for other components to use. It is a
1.0.0 release which is stable for production use, and it powers one built-in report: the Facility
Assignment Configuration Errors report
(`OLMIS-2760 <https://openlmis.atlassian.net/browse/OLMIS-2760>`_).

Additional built-in reports in OpenLMIS 3.3.1 are still powered by their own services. In future
releases, they may be migrated to a new version of this centralized report service.

**Warning**: Developers should take note that the design of this service will be changing with
future releases. Developers and implementers are discouraged from using this 1.0.1 version to build
additional reports.


Requisition Service 6.0.0
-------------------------

Stock Management 3.0.0
----------------------

Service Util 3.1.0
------------------
