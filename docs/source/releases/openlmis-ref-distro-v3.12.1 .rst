====================================
3.12.1 Patch Release Notes - Dec 13, 2021
====================================

Status: Stable
===============

3.12.1 Patch release is recommended for users of OpenLMIS version 3.12.0 because the patch includes a bug fix for invalid pagination on /api/validSources and timeout on /api/validDestinations endpoints.

Patch Release Notes
===================
3.12.1 Patch Release contains the bug fix for

- `OLMIS-7442 <https://openlmis.atlassian.net/browse/OLMIS-7442>`_
- `OLMIS-7387 <https://openlmis.atlassian.net/browse/OLMIS-7387>`_

For information about future planned releases, see the `Living Product Roadmap
<https://openlmis.atlassian.net/wiki/display/OP/Living+Product+Roadmap>`_. Pull requests and
`contributions <http://docs.openlmis.org/en/latest/contribute/contributionGuide.html>`_ are welcome.

Compatibility
-------------

Compatible with OpenLMIS 3.12.0

Download or View on GitHub
--------------------------

`OpenLMIS Reference Distribution 3.12.1
<https://github.com/OpenLMIS/openlmis-ref-distro/releases/tag/v3.12.1>`_

Known Bugs
==========

No known additional bugs were included in this patch release.

To report a bug, see `Reporting Bugs
<http://docs.openlmis.org/en/latest/contribute/contributionGuide.html#reporting-bugs>`_.

New Features
============

No new features were introduced with this patch release.

API Changes
===========

API changes can be found in each service CHANGELOG.md file, found in the root directory of the service repository.

Performance
========================

No manual performance testing was conducted for this patch release.

Test Coverage
=============

OpenLMIS 3.12.1 was tested using the established OpenLMIS Release Candidate process.

`Patch Release 3.12 RC1 Testing <https://openlmis.atlassian.net/plugins/servlet/ac/com.soldevelo.apps.test_management_premium/test-cycle-details#!testCycleId=15706>`_

As part of this process, full manual test cycles were executed for each release candidate published. Any critical or blocker bugs found during the release candidate were resolved in a bug fix cycle with a full manual test cycle executed before releasing the final version 3.12.1. For more details about test executions and bugs found for this release please see .

All Changes by Component
========================

Version 3.12.1 of the Reference Distribution contains updated versions of the components listed
below. The Reference Distribution bundles these component together using Docker to create a complete
OpenLMIS instance. Each component has its own own public GitHub repository (source code) and
DockerHub repository (release image). The Reference Distribution and components are versioned
independently; for details see `Versioning and Releasing
<http://docs.openlmis.org/en/latest/conventions/versioningReleasing.html>`_.

Stock Management 5.1.5
~~~~~~~~~~~~~~~~~~~~~~~

Reference UI 5.2.2
~~~~~~~~~~~~~~~~~~~~~~~

Stock Management-UI 2.1.1
~~~~~~~~~~~~~~~~~~~~~~~

Contributions
=============

Many organizations and individuals around the world have contributed to OpenLMIS version 3 by
serving on our committees (Governance, Product and Technical), requesting improvements, suggesting
features and writing code and documentation. Please visit our GitHub repos to see the list of
individual contributors on the OpenLMIS codebase. If anyone who contributed in GitHub is missing,
please contact the Community Manager.

Further Resources
=================

Please see the Implementer Toolkit on the `OpenLMIS website <http://openlmis.org/get-started/implementer-toolkit/>`_ to learn more about best practicies in implementing OpenLMIS.  Also, learn more about the `OpenLMIS Community <http://openlmis.org/about/community/>`_ and how to get involved!
