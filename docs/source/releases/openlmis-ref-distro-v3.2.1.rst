======================================
3.2.1 Release Notes - 14 November 2017
======================================

Status: Stable
==============

3.2.1 is a stable release, and all users of `OpenLMIS version 3
<https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017>`_ are
encouraged to adopt it.

Release Notes
=============

The release of 3.2.1 is primarily a **bug-fix** and **performance** release, with `over 40 bugs
fixed and over 20 other improvements <https://openlmis.atlassian.net/issues/?jql=status%3DDone%20AND%20project%3DOLMIS%20AND%20fixVersion%3D3.2.1%20and%20type!%3DTest%20and%20type!%3DEpic%20ORDER%20BY%20type%20ASC%2C%20priority%20DESC%2C%20key%20ASC>`_
since 3.2.0 including major improvements in performance.

This release does include some new features; see the New Features section below.

See the `Living Product Roadmap
<https://openlmis.atlassian.net/wiki/display/OP/Living+Product+Roadmap>`_ for information about
future planned releases. Pull requests and `contributions
<http://docs.openlmis.org/en/latest/contribute/contributionGuide.html>`_ are welcome.

Compatibility
-------------

**Important! Stock Management data migration**: OpenLMIS 3.2.1 introduces a new constraint that
forces the adjustment reasons to be unique within each requisition line item. This means that it
will no longer be possible to have two "expired" adjustments in a single product, eg. Expired: 20
and Expired: 30. It will still be possible to have different adjustment reasons, eg. Expired: 20
and Lost: 30. The UI does not allow users to add the same adjustment reason twice starting with
OpenLMIS 3.2.1. Users should now provide a total value for a given adjustment reason.

Due to this change, it is necessary for any existing OpenLMIS implementations to migrate their
stock adjustments data to merge any duplicates. Implementations can do this manually before
upgrading to 3.2.1, otherwise OpenLMIS 3.2.1 will apply a default migration automatically. The
default migration automatically merge the duplicates by adding together the quantities from the
same adjustment reasons in each requisition line item. For instance, if a line item had two
adjustments with the same reason (Expired: 20 and Expired: 30), this will be replaced by a single
adjustment with the total (Expired: 50). We highly recommend that all implementations review their
duplicate stock adjustments manually and determine how they should be merged prior to upgrading to
3.2.1. The default migration may not be valid for all the cases that can occur in real-world data.

**Batch Requisition Approval**: During work on OpenLMIS 3.2.1, further improvements to the Batch
Approval screen were made, but the feature is still not officially supported. The UI screen is
disabled. Implementations can override the code in their local customizations in order to use the
screen. Further changes to the screen are expected in future releases before it is officially
supported. See `OLMIS-3182 <https://openlmis.atlassian.net/browse/OLMIS-3182>`_ for more info.

Backwards-Compatible Except As Noted
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Unless noted here, all other changes to OpenLMIS 3.x are backwards-compatible. All changes to data
or schemas include automated migrations from previous versions back to version 3.0.1. All new or
altered functionality is listed in the sections below for New Features and Changes to Existing
Functionality.

Upgrading from Older Versions
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you are upgrading to OpenLMIS 3.2.1 from OpenLMIS 3.0.x or 3.1.x, please review the `3.2.0
Release Notes <http://docs.openlmis.org/en/latest/releases/openlmis-ref-distro-v3.2.0.html>`_ for
important compatibility information.

For information about upgrade paths from OpenLMIS 1 and 2 to version 3, see the `3.0.0 Release
Notes <https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017>`_.

Download or View on GitHub
--------------------------

`OpenLMIS Reference Distribution 3.2.1
<https://github.com/OpenLMIS/openlmis-ref-distro/releases/tag/v3.2.1>`_

Known Bugs
==========

Bug reports are collected in Jira for troubleshooting, analysis and resolution. See `OpenLMIS 3.2.1
Bugs <https://openlmis.atlassian.net/issues/?jql=project%3DOLMIS%20and%20type%3DBug%20and%20affectedVersion%3D3.2.1%20order%20by%20priority%20DESC%2C%20status%20ASC%2C%20key%20ASC>`_.

To report a bug, see `Reporting Bugs
<http://docs.openlmis.org/en/latest/contribute/contributionGuide.html#reporting-bugs>`_.

New Features
============

OpenLMIS 3.2.1 contains some new features:

- Facility administration screens now support adding and editing facilities
- User administration screens now provide filtering and more password reset options
- Demo data is significantly expanded, including for use in contract tests and performance tests
- `Vaccine MVP 
  <https://openlmis.atlassian.net/wiki/spaces/OP/pages/113144940/Vaccine+MVP>`_ features including
  Ideal Stock Amount (ISA) management and Cold Chain Equipment (CCE) tracking (CCE features are
  released in a Beta version that is not included in the 3.2.1 release)
- Contributions from the Malawi implementation, including a new Extension Point for customizing Order Numbers

Changes to Existing Functionality
=================================

Version 3.2.1 contains changes that impact users of existing functionality. Please review these
changes which may require informing end-users and/or updating your customizations/extensions:

- `OLMIS-3223 <https://openlmis.atlassian.net/browse/OLMIS-3223>`_: Ability to delete skipped
  Requisitions
- `OLMIS-3076 <https://openlmis.atlassian.net/browse/OLMIS-3076>`_: DataIntegrityViolationException
  when trying to remove previous requisition / Average Period Consumption should not calculate
  using Emergency requisition data. This change updates the rules about when it is possible to
  delete older requisitions. It also changes how newer requisitions use past data to compute the
  Average Period Consumption.
- `OLMIS-3246 <https://openlmis.atlassian.net/browse/OLMIS-3246>`_: Ability to hide special reasons
  from Total Losses and Adjustments. This feature provides a new configuration option so that
  administrators can hide selected reasons from end-users.
- `OLMIS-3221 <https://openlmis.atlassian.net/browse/OLMIS-3221>`_ and `OLMIS-3222
  <https://openlmis.atlassian.net/browse/OLMIS-3222>`_: View Orders filtering by period start and
  end dates
- `OLMIS-2700 <https://openlmis.atlassian.net/browse/OLMIS-2700>`_: View Requisition enhancements.
  This includes new sort order controls and make the Date Initiated visible.

See `all 3.2.1 issues tagged 'UIChange' in Jira <https://openlmis.atlassian.net/issues/?jql=status%3DDone%20AND%20project%3DOLMIS%20AND%20fixVersion%3D3.2.1%20and%20type!%3DTest%20and%20type!%3DEpic%20and%20labels%20IN%20(UIChange)%20ORDER%20BY%20type%20ASC%2C%20priority%20DESC%2C%20key%20ASC>`_.

API Changes
===========

Some APIs have changes to their contracts and/or their request-response data structures. These
changes impact developers and systems integrating with OpenLMIS:

- `OLMIS-3254 <https://openlmis.atlassian.net/browse/OLMIS-3254>`_: Unrestrict GET operations on
  certain reference data resources. This makes certain information (EG, lists of all facilities
  and orderables) available for any user with a valid login token.
- **TBD: anything else?**

Performance Improvements
========================

Targeted improvements were made in the RESTful API services as well as in the UI application.
The improvements were chosen based on testing using a new performance data set and by manually
testing with simulated conditions (EG, network set to 3G slow).

**TBD: pull in chart and describe top performance improvements summarized in slack conversation; link to wiki source for data**

All Changes by Component
========================

Version 3.2.1 of the Reference Distribution contains updated versions of the components listed
below. The Reference Distribution bundles these component together using Docker to create a complete
OpenLMIS instance. Each component has its own own public GitHub repository (source code) and
DockerHub repository (release image). The Reference Distribution and components are versioned
independently; for details see `Versioning and Releasing
<http://docs.openlmis.org/en/latest/conventions/versioningReleasing.html>`_.

Auth Service 3.1.1
------------------

- **TBD**

Source: `Auth CHANGELOG <https://github.com/OpenLMIS/openlmis-auth/blob/master/CHANGELOG.md>`_

CCE Service 1.0.0-beta
----------------------

This component is a **beta** of new Cold Chain Equipment functionality to support Vaccines in
medical supply chains. This API service component has an accompanying beta CCE UI component.

For details, see the functional documentation: `Cold Chain Equipment Management
<https://openlmis.atlassian.net/wiki/spaces/OP/pages/113145252/Cold+Chain+Equipment+Management>`_

*Warning: This is a beta component, and is not yet intended for production use. APIs and
functionality are still subject to change until the official release.*

Fulfillment Service 6.1.0
-------------------------

- **TBD**

Source: `Fulfillment CHANGELOG
<https://github.com/OpenLMIS/openlmis-fulfillment/blob/master/CHANGELOG.md>`_

Notification Service 3.0.4
--------------------------

- **TBD**

Source: `Notification CHANGELOG
<https://github.com/OpenLMIS/openlmis-notification/blob/master/CHANGELOG.md>`_

Reference Data Service 9.0.0
----------------------------

- **TBD**

Source: `ReferenceData CHANGELOG
<https://github.com/OpenLMIS/openlmis-referencedata/blob/master/CHANGELOG.md>`_

Reference UI 5.0.4
------------------

- **TBD**

auth-ui 6.0.0
~~~~~~~~~~~~~

- **TBD**

See `openlmis-auth-ui CHANGELOG
<https://github.com/OpenLMIS/openlmis-auth-ui/blob/master/CHANGELOG.md>`_

cce-ui 1.0.0-beta
~~~~~~~~~~~~~~~~~

Beta release of `CCE UI <https://github.com/OpenLMIS/openlmis-cce-ui>`_. See CCE service component
above for more info.

fulfillment-ui 5.1.0
~~~~~~~~~~~~~~~~~~~~

- **TBD**

See `openlmis-fulfillment-ui CHANGELOG
<https://github.com/OpenLMIS/openlmis-fulfillment-ui/blob/master/CHANGELOG.md>`_

referencedata-ui 5.2.2
~~~~~~~~~~~~~~~~~~~~~~

- **TBD**

See `openlmis-referencedata-ui CHANGELOG
<https://github.com/OpenLMIS/openlmis-referencedata-ui/blob/master/CHANGELOG.md>`_

report-ui 5.0.4
~~~~~~~~~~~~~~~

- **TBD**

See `openlmis-report-ui CHANGELOG
<https://github.com/OpenLMIS/openlmis-report-ui/blob/master/CHANGELOG.md>`_

requisition-ui 5.2.0
~~~~~~~~~~~~~~~~~~~~

- **TBD**

See `openlmis-requisition-ui CHANGELOG
<https://github.com/OpenLMIS/openlmis-requisition-ui/blob/master/CHANGELOG.md>`_

stockmanagement-ui 1.0.1
~~~~~~~~~~~~~~~~~~~~~~~~

- **TBD (and add CHANGELOG)**

ui-components 5.2.0
~~~~~~~~~~~~~~~~~~~

- **TBD**

See `openlmis-ui-components CHANGELOG
<https://github.com/OpenLMIS/openlmis-ui-components/blob/master/CHANGELOG.md>`_

ui-layout:5.0.3
~~~~~~~~~~~~~~~

- **TBD**

See `openlmis-ui-layout CHANGELOG
<https://github.com/OpenLMIS/openlmis-ui-layout/blob/master/CHANGELOG.md>`_

Dev UI
~~~~~~

The `Dev UI developer tooling <https://github.com/OpenLMIS/dev-ui>`_ has advanced to v6.

Report Service 1.0.0
--------------------

This new service is intended to provide reporting functionality for other components to use. It is a
1.0.0 release which is stable for production use, and it powers one built-in report (the Facility
Assignment Configuration Errors report).

**Warning**: Developers should take note that its design will be changing with future releases.
Developers and implementers are discouraged from using this 1.0.0 version to build additional
reports.

Current report functionality:

- `OLMIS-2760 <https://openlmis.atlassian.net/browse/OLMIS-2760>`_: Facility Assignment
  Configuration Errors

Additional built-in reports in OpenLMIS 3.2.0 are still powered by their own services. In future
releases, they may be migrated to a new version of this centralized report service.

Requisition Service 5.1.0
-------------------------

- **TBD**

Source: `Requisition CHANGELOG
<https://github.com/OpenLMIS/openlmis-requisition/blob/master/CHANGELOG.md>`_

Stock Management 2.0.0
----------------------

- **TBD (and add CHANGELOG link)**

Components with No Changes
==========================

Other tooling components have not changed, including: the `logging service
<https://github.com/OpenLMIS/openlmis-rsyslog>`_, log image, scalyr image, **TBD**, nginx image, consul image, Postgres 9.6-postgis
image, and a library for shared Java code called `service-util <https://github.com/OpenLMIS/openlmis-service-util>`_.

Contributions
=============

Thanks to the Malawi implementation team who has contributed a number of pull requests to add
functionality and customization in ways that have global shared benefit.

For a detailed list of contributors, see the Release Notes for OpenLMIS 3.2.0, 3.1.0 and 3.0.0.

Further Resources
=================

Learn more about the `OpenLMIS Community <http://openlmis.org/about/community/>`_ and how to get
involved!
