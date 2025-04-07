=====================================
3.19.1 Release Notes - April 07, 2025
=====================================

Status: Stable
==============
Version 3.19.1 has been released to address a critical migration issue identified after the 3.19 deployment.

New Features
============
- No new features have been added since version 3.19.

Improvements
============
- No improvements have been added since version 3.19.

Bug Fixes
==========
- **Fixed migration issue**: Resolved an issue where migration scripts were failing for implementations using SUPERSET. Due to this, the Reference Data Service was unable to start after the upgrade. The migration process has been corrected to ensure a smooth upgrade and that all services, including the Reference Data Service, start and function correctly.

Compatibility
=============
**Important Notice** for Implementers Using a Custom Reports Service Forked from Core:
If you are using a forked version of the core reports service, ensure your implementation is updated to include the latest changes required for Dashboard reports in version 3.19.1.

For the necessary updates, refer to the following repository:
OpenLMIS Reports - `<https://github.com/OpenLMIS/openlmis-report/tree/rel-1.4.0-hotfix>`_

All other changes to OpenLMIS 3.x remain backwards-compatible. Any changes to data or schemas are accompanied by automated migrations from previous versions back to version 3.0.1.

All Changes by Component
========================
Version 3.19.1 of the Reference Distribution contains updated versions of the components listed below. The Reference Distribution bundles these components together using Docker to create a complete OpenLMIS instance. Each component has its own public GitHub repository (source code) and DockerHub repository (release image). The Reference Distribution and components are versioned independently.

- **BE Components**:
    - **Reference Data Service 15.3.0-hotfix** - `ReferenceData CHANGELOG <https://github.com/OpenLMIS/openlmis-referencedata/blob/rel-15.3.0-hotfix/CHANGELOG.md>`_
    - **Report Service 1.4.0-hotfix** - `Report CHANGELOG <https://github.com/OpenLMIS/openlmis-report/blob/rel-1.4.0-hotfix/CHANGELOG.md>`_
        - This service provides reporting functionality for other components to use. Built-in reports in OpenLMIS 3.4.0 are still powered by their own services. In future releases, they may be migrated to this centralized report service.
        - **Warning**: Developers should note that the design of this service will be changing in future releases. The 1.4.x version is not recommended for building additional reports.

Components with No Changes
==========================
- **BE Components**:
    - **Auth Service 4.3.5** - `Auth CHANGELOG <https://github.com/OpenLMIS/openlmis-auth/blob/rel-4.3.5/CHANGELOG.md>`_
    - **CCE Service 1.3.5** - `CCE CHANGELOG <https://github.com/OpenLMIS/openlmis-cce/blob/rel-1.3.5/CHANGELOG.md>`_
    - **Fulfillment Service 9.2.0** - `Fulfillment CHANGELOG <https://github.com/OpenLMIS/openlmis-fulfillment/blob/rel-9.2.0/CHANGELOG.md>`_
    - **Notification Service 4.3.5** - `Notification CHANGELOG <https://github.com/OpenLMIS/openlmis-notification/blob/rel-4.3.5/CHANGELOG.md>`_
    - **Requisition Service 8.4.0** - `Requisition CHANGELOG <https://github.com/OpenLMIS/openlmis-requisition/blob/rel-8.4.0/CHANGELOG.md>`_
    - **Stock Management 5.2.0** - `Stock Management CHANGELOG <https://github.com/OpenLMIS/openlmis-stockmanagement/blob/rel-5.2.0/CHANGELOG.md>`_
    - **Hapifhir 2.0.4** - `Hapifhir CHANGELOG <https://github.com/OpenLMIS/openlmis-hapifhir/blob/rel-2.0.4/CHANGELOG.md>`_
    - **Diagnostics 1.1.4** - `Diagnostics CHANGELOG <https://github.com/OpenLMIS/openlmis-diagnostics/blob/rel-1.1.4/CHANGELOG.md>`_
    - **BUQ 1.0.2** - `BUQ CHANGELOG <https://github.com/OpenLMIS/openlmis-buq/blob/rel-1.0.2/CHANGELOG.md>`_
    - **Dhis2 Integration 1.0.1** - `Dhis2 Integration CHANGELOG <https://github.com/OpenLMIS/openlmis-dhis2-integration/blob/rel-1.0.1/CHANGELOG.md>`_

- **UI Components and Services**:
    - **Reference UI 5.2.11** - `The Reference UI <https://github.com/OpenLMIS/openlmis-reference-ui/tree/rel-5.2.11>`_
        - The Reference UI is the web-based user interface for the OpenLMIS Reference Distribution. This user interface is a single page web application that is optimized for offline and low-bandwidth environments. Compiled together from module UI modules using Docker compose along with the OpenLMIS dev-ui.
    - **Reference Data-UI 5.6.16** - `ReferenceData-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-referencedata-ui/blob/rel-5.6.16/CHANGELOG.md>`_
    - **Auth-UI 6.2.15** - `Auth-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-auth-ui/blob/rel-6.2.15/CHANGELOG.md>`_
    - **CCE-UI 1.1.7** - `CCE-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-cce-ui/blob/rel-1.1.7/CHANGELOG.md>`_
    - **Fulfillment-UI 6.1.6** - `Fulfillment-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-fulfillment-ui/blob/rel-6.1.6/CHANGELOG.md>`_
    - **Report-UI 5.2.14** - `Report-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-report-ui/blob/rel-5.2.14/CHANGELOG.md>`_
    - **Requisition-UI 7.0.14** - `Requisition-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-requisition-ui/blob/rel-7.0.14/CHANGELOG.md>`_
    - **Stock Management-UI 2.1.8** - `Stock Management-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-stockmanagement-ui/blob/rel-2.1.8/CHANGELOG.md>`_
    - **UI-Components 7.2.13** - `UI-Components CHANGELOG <https://github.com/OpenLMIS/openlmis-ui-components/blob/rel-7.2.13/CHANGELOG.md>`_
    - **UI-Layout 5.2.8** - `UI-Layout CHANGELOG <https://github.com/OpenLMIS/openlmis-ui-layout/blob/rel-5.2.8/CHANGELOG.md>`_
    - **Dev UI 9.0.7** - `Dev-UI CHANGLOG <https://github.com/OpenLMIS/dev-ui/blob/rel-9.0.7/CHANGELOG.md>`_


Upgrading from Older Versions
=============================
If you are upgrading from OpenLMIS 3.0.x or 3.1.x (without first upgrading to 3.2.x), please review the `3.2.0
Release Notes <http://docs.openlmis.org/en/latest/releases/openlmis-ref-distro-v3.2.0.html>`_ for important compatibility information about a required PostgreSQL extension and data migrations.

For information about upgrade paths from OpenLMIS 1 and 2 to version 3, see the `3.0.0 Release
Notes <https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017>`_.

If you are upgrading to version 3.19.1, the SUPERSET reports will need to be added manually by system administrators.
A `short manual is available here: <https://github.com/OpenLMIS/openlmis-report/blob/rel-1.4.0-hotfix/CHANGELOG.md#140-hotfix--2025-04-04>`_

Test Coverage
=============
Version 3.19.1 was released due to the critical migration issue identified after 3.19. Full regression testing was conducted for version 3.19. Since version 3.19.1 contains no new features and only fixes the migration issue, full regression testing was not required.

Download or View on GitHub
==========================
`OpenLMIS Reference Distribution 3.19.1
<https://github.com/OpenLMIS/openlmis-ref-distro/releases/tag/v3.19.1>`_

Known Issues
============
Bug reports are collected in Jira for troubleshooting, analysis, and resolution on an ongoing basis. See `OpenLMIS 3.19.1 Bugs <https://openlmis.atlassian.net/issues/?jql=type%20%3D%20Bug%20and%20project%20%3D%20%22OpenLMIS%20General%22%20AND%20status%20not%20in%20(Done%2CCanceled)&startIndex=200>`_ for the current list of known bugs.

To report a bug, see `Reporting Bugs
<http://docs.openlmis.org/en/latest/contribute/contributionGuide.html#reporting-bugs>`_.

Contributions
=============
Many organizations and individuals around the world have contributed to OpenLMIS version 3 by serving on committees (Governance, Product, and Technical), requesting improvements, suggesting features, and writing code and documentation. Please visit our GitHub repositories to see the list of individual contributors to the OpenLMIS codebase. If anyone who contributed on GitHub is missing, please contact the Community Manager. Technical development of OpenLMIS is conducted by `SolDevelo <https://soldevelo.com>`_.

Further Resources
=================
Please see the Implementer Toolkit on the `OpenLMIS website <http://openlmis.org/get-started/implementer-toolkit/>`_ to learn more about best practices in implementing OpenLMIS. Also, learn more about the `OpenLMIS Community <http://openlmis.org/about/community/>`_ and how to get involved!
