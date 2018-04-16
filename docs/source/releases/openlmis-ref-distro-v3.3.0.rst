=================================
3.3.0 Release Notes - COMING SOON
=================================

Status: Stable
==============

3.3.0 is a stable release, and all users of `OpenLMIS version 3
<https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017>`_ are
encouraged to adopt it.

Release Notes
=============

The OpenLMIS Community is excited to announce the **3.3.0 release** of OpenLMIS! It is another
major milestone in the version 3 `re-architecture <https://openlmis.atlassian.net/wiki/display/OP/Re-Architecture>`_
that allows more functionality to be shared among the community of OpenLMIS users.

3.3.0 includes new [LIST KEY NEW FEATURES BY NAME...SEE PREVIOUS RELEASE NOTES FOR EXAMPLES]

For a full list of features and bug-fixes since 3.2.1, see `OpenLMIS 3.3.0 Jira tickets
<https://openlmis.atlassian.net/issues/?jql=status%3DDone%20AND%20project%3DOLMIS%20AND%20fixVersion%3D3.3%20and%20type!%3DTest%20and%20type!%3DEpic%20ORDER%20BY%20type%20ASC%2C%20priority%20DESC%2C%20key%20ASC>`_.

For information about future planned releases, see the `Living Product Roadmap
<https://openlmis.atlassian.net/wiki/display/OP/Living+Product+Roadmap>`_. Pull requests and
`contributions <http://docs.openlmis.org/en/latest/contribute/contributionGuide.html>`_ are welcome.

Compatibility
-------------

[ADD PARAGRAPHS HERE TO EXPLAIN ANY COMPATIBILITY ISSUES, SUCH AS MANUAL DATA MIGRATIONS, NEW
DEPENDENCIES, ETC.]

**Batch Requisition Approval**: The Batch Approval screen, which was improved in OpenLMIS 3.2.1,
is still not officially supported. The UI screen is disabled by default. Implementations can
override the code in their local customizations in order to use the screen. Further performance
improvements are needed before the screen is officially supported. See `OLMIS-3182
<https://openlmis.atlassian.net/browse/OLMIS-3182>`_ and the tickets linked to it for details.

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

`OpenLMIS Reference Distribution 3.3.0
<https://github.com/OpenLMIS/openlmis-ref-distro/releases/tag/v3.3.0>`_

Known Bugs
==========

Bug reports are collected in Jira for troubleshooting, analysis and resolution. See `OpenLMIS 3.3.0
Bugs <https://openlmis.atlassian.net/issues/?jql=project%3DOLMIS%20and%20type%3DBug%20and%20affectedVersion%3D3.3%20order%20by%20priority%20DESC%2C%20status%20ASC%2C%20key%20ASC>`_.

To report a bug, see `Reporting Bugs
<http://docs.openlmis.org/en/latest/contribute/contributionGuide.html#reporting-bugs>`_.

New Features
============

OpenLMIS 3.3.0 contains these new features:

- [MAKE A BULLETTED LIST TO EXPLAIN KEY NEW FEATURES...SEE PREVIOUS RELEASE NOTES FOR EXAMPLES]
- MAYBE REFERENCE THE `Vaccine MVP 
  <https://openlmis.atlassian.net/wiki/spaces/OP/pages/113144940/Vaccine+MVP>`_ features.

Changes to Existing Functionality
=================================

Version 3.3.0 contains changes that impact users of existing functionality. Please review these
changes which may require informing end-users and/or updating your customizations/extensions:

- [MAKE A BULLETTED LIST OF ANY SIGNIFICANT CHANGES...SEE PREVIOUS RELEASE NOTES FOR EXAMPLES]

See `all 3.3.0 issues tagged 'UIChange' in Jira <https://openlmis.atlassian.net/issues/?jql=status%3DDone%20AND%20project%3DOLMIS%20AND%20fixVersion%3D3.3%20and%20type!%3DTest%20and%20type!%3DEpic%20and%20labels%20IN%20(UIChange)%20ORDER%20BY%20type%20ASC%2C%20priority%20DESC%2C%20key%20ASC>`_.

API Changes
===========

Some APIs have changes to their contracts and/or their request-response data structures. These
changes impact developers and systems integrating with OpenLMIS:

- [MAKE A BULLETTED LIST OF API CHANGES...SEE PREVIOUS RELEASE NOTES FOR EXAMPLES]

Performance Improvements
========================

[EXPLAIN CURRENT DEVELOPMENTS IN PERFORMANCE. WE HAVE REPEATED THE MANUAL TESTS TO ENSURE NO
REGRESSIONS. WE HAVE INCREASED DATA SETS FOR PERFORMANCE TESTING OF NEW FEATURES, AND ADDED
NEW AUTOMATED TESTS. WE HAVE AN END-TO-END FRAMEWORK THAT WILL NOW LET US BUILD EVEN MORE
TESTS SO PERF TESTING CAN BE DONE MOSTLY AUTOMATED NOT MANUAL IN THE FUTURE.]

[MAY WANT TO ADD A GRAPH AND LINKS TO STATS AND WIKI. SEE PREVIOUS RELEASE NOTES FOR EXAMPLES.]

Test Coverage
=============

OpenLMIS 3.3.0 is the second release using the new `Release Candidate process
<http://docs.openlmis.org/en/latest/conventions/versioningReleasing.html#release-process>`_. As part
of this process, a full manual regression test cycle was conducted, and multiple release candidates
were published to address critical bugs before releasing the final version 3.3.0.

Manual tests were conducted using a set of [NNN] Zephyr tests tracked in Jira. A total of [ZZ] bugs were
found during testing. The full set of tests was executed on the first Release Candidate (RC1).

[EXPLAIN ROUNDS OF TESTING. SEE PREVIOUS RELEASE NOTES FOR EXAMPLE. CONSIDER CSV FILE AS BEFORE.]

The automated tests (unit tests, integration tests, and contract tests) were 100% passing at the time
of the 3.3.0 release. Automated test coverage is tracked in `Sonar
<http://sonar.openlmis.org/projects>`_.

All Changes by Component
========================

[INSERT SUB-HEADINGS FOR EACH COMPONENT LISTING ITS VERSION AND ALL IMPROVEMENTS FROM CHANGELOGS]

Version 3.3.0 of the Reference Distribution contains updated versions of the components listed
below. The Reference Distribution bundles these component together using Docker to create a complete
OpenLMIS instance. Each component has its own own public GitHub repository (source code) and
DockerHub repository (release image). The Reference Distribution and components are versioned
independently; for details see `Versioning and Releasing
<http://docs.openlmis.org/en/latest/conventions/versioningReleasing.html>`_.

Auth Service X.Y.Z
------------------

Source: `Auth CHANGELOG <https://github.com/OpenLMIS/openlmis-auth/blob/master/CHANGELOG.md>`_

CCE Service X.Y.Z
-----------------

Fulfillment Service X.Y.Z
-------------------------

Source: `Fulfillment CHANGELOG
<https://github.com/OpenLMIS/openlmis-fulfillment/blob/master/CHANGELOG.md>`_

Notification Service X.Y.Z
--------------------------

Source: `Notification CHANGELOG
<https://github.com/OpenLMIS/openlmis-notification/blob/master/CHANGELOG.md>`_

Reference Data Service X.Y.Z
----------------------------

Source: `ReferenceData CHANGELOG
<https://github.com/OpenLMIS/openlmis-referencedata/blob/master/CHANGELOG.md>`_

Reference UI X.Y.Z
------------------

The Reference UI (`https://github.com/OpenLMIS/openlmis-reference-ui/ <https://github.com/OpenLMIS/openlmis-reference-ui/>`_)
is the web-based user interface for the OpenLMIS Reference Distribution. This user interface is
a single page web application that is optimized for offline and low-bandwidth environments.
The Reference UI is compiled together from module UI modules using Docker compose along with the
OpenLMIS dev-ui. UI modules included in the Reference UI are:

auth-ui X.Y.Z
~~~~~~~~~~~~~

See `openlmis-auth-ui CHANGELOG
<https://github.com/OpenLMIS/openlmis-auth-ui/blob/master/CHANGELOG.md>`_

cce-ui X.Y.Z
~~~~~~~~~~~~

fulfillment-ui X.Y.Z
~~~~~~~~~~~~~~~~~~~~

See `openlmis-fulfillment-ui CHANGELOG
<https://github.com/OpenLMIS/openlmis-fulfillment-ui/blob/master/CHANGELOG.md>`_

referencedata-ui X.Y.Z
~~~~~~~~~~~~~~~~~~~~~~

See `openlmis-referencedata-ui CHANGELOG
<https://github.com/OpenLMIS/openlmis-referencedata-ui/blob/master/CHANGELOG.md>`_

report-ui X.Y.Z
~~~~~~~~~~~~~~~

See `openlmis-report-ui CHANGELOG
<https://github.com/OpenLMIS/openlmis-report-ui/blob/master/CHANGELOG.md>`_

requisition-ui X.Y.Z
~~~~~~~~~~~~~~~~~~~~

See `openlmis-requisition-ui CHANGELOG
<https://github.com/OpenLMIS/openlmis-requisition-ui/blob/master/CHANGELOG.md>`_

stockmanagement-ui X.Y.Z
~~~~~~~~~~~~~~~~~~~~~~~~

See `openlmis-ui-components CHANGELOG
<https://github.com/OpenLMIS/openlmis-stockmanagement-ui/blob/master/CHANGELOG.md>`_

ui-components X.Y.Z
~~~~~~~~~~~~~~~~~~~

See `openlmis-ui-components CHANGELOG
<https://github.com/OpenLMIS/openlmis-ui-components/blob/master/CHANGELOG.md>`_

ui-layout X.Y.Z
~~~~~~~~~~~~~~~

See `openlmis-ui-layout CHANGELOG
<https://github.com/OpenLMIS/openlmis-ui-layout/blob/master/CHANGELOG.md>`_

Dev UI v7
~~~~~~~~~

The `Dev UI developer tooling <https://github.com/OpenLMIS/dev-ui>`_ has advanced to v7.

Report Service X.Y.Z
--------------------

This service is intended to provide reporting functionality for other components to use. It is a
1.0.0 release which is stable for production use, and it powers one built-in report: the Facility
Assignment Configuration Errors report
(`OLMIS-2760 <https://openlmis.atlassian.net/browse/OLMIS-2760>`_).

Additional built-in reports in OpenLMIS 3.3.0 are still powered by their own services. In future
releases, they may be migrated to a new version of this centralized report service.

**Warning**: Developers should take note that the design of this service will be changing with
future releases. Developers and implementers are discouraged from using this 1.0.0 version to build
additional reports.

Requisition Service X.Y.Z
-------------------------

Source: `Requisition CHANGELOG
<https://github.com/OpenLMIS/openlmis-requisition/blob/master/CHANGELOG.md>`_

Stock Management X.Y.Z
----------------------

Source: `Stock Management CHANGELOG
<https://github.com/OpenLMIS/openlmis-stockmanagement/blob/master/CHANGELOG.md>`_

Components with No Changes
==========================

[NEED TO CONFIRM THIS LIST]

Other tooling components have not changed, including: the `logging service
<https://github.com/OpenLMIS/openlmis-rsyslog>`_, the Consul-friendly distribution of
`nginx <https://github.com/OpenLMIS/openlmis-nginx>`_, the docker `Postgres 9.6-postgis image
<https://github.com/OpenLMIS/postgres>`_, the docker `rsyslog image
<https://github.com/OpenLMIS/openlmis-rsyslog>`_, the docker `scalyr image
<https://github.com/OpenLMIS/openlmis-scalyr>`_, and a library for shared Java code called `service-util <https://github.com/OpenLMIS/openlmis-service-util>`_.

Contributions
=============

Many organizations and individuals around the world have contributed to OpenLMIS version 3 by
serving on committees, bringing the community together, and of course writing code and
documentation. Below is a list of those who contributed code or documentation into the GitHub
repos. If anyone who contributed in GitHub is missing, please contact the Community Manager.

Thanks to the Malawi implementation team who has continued to contribute a number of changes
that have global shared benefit.

[NEED TO DECIDE IF WE ARE GOING TO LIST ALL CONTRIBUTORS BY NAME AGAIN. MAYBE WE SHOULD ALSO
LIST THOSE WHO SERVED ON COMMITTEES SO IT IS CLEAR WHAT ORGANIZATIONS GUIDED THIS RELEASE.]

For a detailed list of contributors to previous versions, see the Release Notes for OpenLMIS 3.2.0,
3.1.0 and 3.0.0.

Further Resources
=================

Learn more about the `OpenLMIS Community <http://openlmis.org/about/community/>`_ and how to get
involved!
