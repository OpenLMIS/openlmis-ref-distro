=====================================
3.19.2 Release Notes - November 28, 2025
=====================================

Status: Stable
==============

3.19.2 is a stable release, and all users of `OpenLMIS version 3
<https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017>`_ are
encouraged to adopt it.

New Features
============
- Pack/Dose Toggle - Users can now seamlessly switch between packs and doses while working in Stock Management or Requisition workflows.
- Enhanced User Visibility on Stock Cards - Stock card operations now display the user who performed each action, improving traceability and accountability during stock management activities.

Improvements
============
- Improved User Import Process - The user import functionality now supports assigning roles directly during import. Additionally, the `isEmailVerified` field has been removed from the import process to reduce complexity.
- Added support for PostgreSQL 14.

Bug Fixes
==========
- Prevent Lodash override by locking global _ to underscore

Compatibility
=============
**Important Notice** for Implementers Using a Custom Reports Service Forked from Core (**Since 3.19.1**):
If you are using a forked version of the core reports service, ensure your implementation is updated to include the latest changes required for Dashboard reports.

For the necessary updates, refer to the following repository:
OpenLMIS Reports - `<https://github.com/OpenLMIS/openlmis-report/tree/rel-1.4.0-hotfix>`_

All other changes to OpenLMIS 3.x remain backwards-compatible. Any changes to data or schemas are accompanied by automated migrations from previous versions back to version 3.0.1.

All Changes by Component
========================
Version 3.19.2 of the Reference Distribution contains updated versions of the components listed below. The Reference Distribution bundles these components together using Docker to create a complete OpenLMIS instance. Each component has its own public GitHub repository (source code) and DockerHub repository (release image). The Reference Distribution and components are versioned independently.

- **BE Components**:
    - **Auth Service 4.4.0** - `Auth CHANGELOG <https://github.com/OpenLMIS/openlmis-auth/blob/rel-4.4.0/CHANGELOG.md>`_
    - **CCE Service 1.4.0** - `CCE CHANGELOG <https://github.com/OpenLMIS/openlmis-cce/blob/rel-1.4.0/CHANGELOG.md>`_
    - **Fulfillment Service 9.3.0** - `Fulfillment CHANGELOG <https://github.com/OpenLMIS/openlmis-fulfillment/blob/rel-9.3.0/CHANGELOG.md>`_
    - **Notification Service 4.4.0** - `Notification CHANGELOG <https://github.com/OpenLMIS/openlmis-notification/blob/rel-4.4.0/CHANGELOG.md>`_
    - **Requisition Service 8.5.0** - `Requisition CHANGELOG <https://github.com/OpenLMIS/openlmis-requisition/blob/rel-8.5.0/CHANGELOG.md>`_
    - **Stock Management 5.3.0** - `Stock Management CHANGELOG <https://github.com/OpenLMIS/openlmis-stockmanagement/blob/rel-5.3.0/CHANGELOG.md>`_
    - **Hapifhir 2.1.0** - `Hapifhir CHANGELOG <https://github.com/OpenLMIS/openlmis-hapifhir/blob/rel-2.1.0/CHANGELOG.md>`_
    - **BUQ 1.1.0** - `BUQ CHANGELOG <https://github.com/OpenLMIS/openlmis-buq/blob/rel-1.1.0/CHANGELOG.md>`_
    - **Dhis2 Integration 1.1.0** - `Dhis2 Integration CHANGELOG <https://github.com/OpenLMIS/openlmis-dhis2-integration/blob/rel-1.1.0/CHANGELOG.md>`_
    - **Reference Data Service 15.4.0** - `ReferenceData CHANGELOG <https://github.com/OpenLMIS/openlmis-referencedata/blob/rel-15.4.0/CHANGELOG.md>`_
    - **Report Service 1.5.0** - `Report CHANGELOG <https://github.com/OpenLMIS/openlmis-report/blob/rel-1.5.0/CHANGELOG.md>`_
        - This service provides reporting functionality for other components to use. Built-in reports in OpenLMIS 3.4.0 are still powered by their own services. In future releases, they may be migrated to this centralized report service.
        - **Warning**: Developers should note that the design of this service will be changing in future releases. The 1.5.x version is not recommended for building additional reports.

- **UI Components and Services**:
    - **Reference Data-UI 5.6.17** - `ReferenceData-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-referencedata-ui/blob/rel-5.6.17/CHANGELOG.md>`_
    - **Fulfillment-UI 6.1.7** - `Fulfillment-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-fulfillment-ui/blob/rel-6.1.7/CHANGELOG.md>`_
    - **Requisition-UI 7.0.15** - `Requisition-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-requisition-ui/blob/rel-7.0.15/CHANGELOG.md>`_
    - **Stock Management-UI 2.1.9** - `Stock Management-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-stockmanagement-ui/blob/rel-2.1.9/CHANGELOG.md>`_
    - **UI-Components 7.2.14** - `UI-Components CHANGELOG <https://github.com/OpenLMIS/openlmis-ui-components/blob/rel-7.2.14/CHANGELOG.md>`_
    - **Dev UI 9.0.8** - `Dev-UI CHANGLOG <https://github.com/OpenLMIS/dev-ui/blob/rel-9.0.8/CHANGELOG.md>`_

Components with No Changes
==========================
- **BE Components**:
    - **Diagnostics 1.1.4** - `Diagnostics CHANGELOG <https://github.com/OpenLMIS/openlmis-diagnostics/blob/rel-1.1.4/CHANGELOG.md>`_

- **UI Components and Services**:
    - **Reference UI 5.2.12** - `The Reference UI <https://github.com/OpenLMIS/openlmis-reference-ui/tree/rel-5.2.12>`_
      - The Reference UI is the web-based user interface for the OpenLMIS Reference Distribution. This user interface is a single page web application that is optimized for offline and low-bandwidth environments. Compiled together from module UI modules using Docker compose along with the OpenLMIS dev-ui.
    - **Auth-UI 6.2.16** - `Auth-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-auth-ui/blob/rel-6.2.16/CHANGELOG.md>`_
    - **UI-Layout 5.2.9** - `UI-Layout CHANGELOG <https://github.com/OpenLMIS/openlmis-ui-layout/blob/rel-5.2.9/CHANGELOG.md>`_
    - **Report-UI 5.2.15** - `Report-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-report-ui/blob/rel-5.2.15/CHANGELOG.md>`_
    - **CCE-UI 1.1.8** - `CCE-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-cce-ui/blob/rel-1.1.8/CHANGELOG.md>`_
    - **Offline UI 1.0.8** - `Offline UI CHANGLOG <https://github.com/OpenLMIS/one-network-integration-ui/blob/rel-0.0.7/CHANGELOG.md>`_
    - **One Network Integration UI 0.0.7** - `One Network Integration UI CHANGLOG <https://github.com/OpenLMIS/dev-ui/blob/rel-9.0.7/CHANGELOG.md>`_

Upgrading from Older Versions
=============================
If you are upgrading from OpenLMIS 3.0.x or 3.1.x (without first upgrading to 3.2.x), please review the `3.2.0
Release Notes <http://docs.openlmis.org/en/latest/releases/openlmis-ref-distro-v3.2.0.html>`_ for important compatibility information about a required PostgreSQL extension and data migrations.

For information about upgrade paths from OpenLMIS 1 and 2 to version 3, see the `3.0.0 Release
Notes <https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017>`_.

If you are upgrading to version 3.19.1 or greater, the SUPERSET reports will need to be added manually by system administrators.
A `short manual is available here: <https://github.com/OpenLMIS/openlmis-report/blob/rel-1.4.0-hotfix/CHANGELOG.md#140-hotfix--2025-04-04>`_

Test Coverage
=============
OpenLMIS 3.19.2 was tested using the established OpenLMIS Release Candidate process. As part of this process, chosen manual test cases were executed to address each change. Any critical or blocker bugs found during the release candidate were resolved.

Download or View on GitHub
==========================
`OpenLMIS Reference Distribution 3.19.2
<https://github.com/OpenLMIS/openlmis-ref-distro/releases/tag/v3.19.2>`_

Known Issues
============
- Report Limitations: The Packs/Doses feature is not available when generating Stock Card and Stock Card Summary reports.
- Batch Approval: Packs/Doses are not supported in the batch approve requisition view.
- POD Compatibility: Packs/Doses are not supported in the POD creation.
- Create Order View (Packs Mode):
  - The doses input is disabled when the Net Content of a product is equal to one.
  - The submit modal always displays quantity in doses, regardless of selected mode.
- Order Fulfillment: Quantity shipped must always be provided in packs.

Other bugs are collected in Jira for troubleshooting, analysis, and resolution on an ongoing basis. See `OpenLMIS 3.19.2 Bugs <https://openlmis.atlassian.net/issues/?jql=type%20%3D%20Bug%20and%20project%20%3D%20%22OpenLMIS%20General%22%20AND%20status%20not%20in%20(Done%2CCanceled)&startIndex=200>`_ for the current list of known bugs.

To report a bug, see `Reporting Bugs
<http://docs.openlmis.org/en/latest/contribute/contributionGuide.html#reporting-bugs>`_.

Contributions
=============
Many organizations and individuals around the world have contributed to OpenLMIS version 3 by serving on committees (Governance, Product, and Technical), requesting improvements, suggesting features, and writing code and documentation. Please visit our GitHub repositories to see the list of individual contributors to the OpenLMIS codebase. If anyone who contributed on GitHub is missing, please contact the Community Manager. Technical development of OpenLMIS is conducted by `SolDevelo <https://soldevelo.com>`_.

Further Resources
=================
Please see the Implementer Toolkit on the `OpenLMIS website <http://openlmis.org/get-started/implementer-toolkit/>`_ to learn more about best practices in implementing OpenLMIS. Also, learn more about the `OpenLMIS Community <http://openlmis.org/about/community/>`_ and how to get involved!
