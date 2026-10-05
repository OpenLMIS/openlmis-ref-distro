======================================
3.20.1 Release Notes - October 5, 2026
======================================

Status: Stable
==============
Version 3.20.1 is a patch release that speeds up the requisition workflow for programs with large product lists. All users of 3.20.0 are encouraged to upgrade.

New Features
============
- No new features have been added since version 3.20.0.

Improvements
============
- Requisition workflow performance for programs with large product lists. Measured on a copy of the UAT database with a 1,003 line item requisition and 9,000 available products:

  - A full non stock-based requisition cycle (initiate, save, submit, authorize, approve) takes 27 seconds instead of 28 minutes, and steps no longer hit the gateway timeout.
  - A full stock-based requisition cycle takes 2.6 minutes instead of 60 minutes.
  - Creating the order on final approval takes 2 seconds instead of 74 seconds.

- The requisition audit log stores the available products as one value of the requisition snapshot instead of a separate snapshot per product, so saving a requisition no longer compares every available product one by one.
- Stock-based requisitions request stock card range summaries only for the products that are used, and the stock management service queries stock on hand history only for the stock cards of the requested products.
- The order CSV export looks up the facility, processing period and program once per order, and fetches products in one batch instead of once per cell.

Bug Fixes
==========
- No bug fixes have been added since version 3.20.0.

Compatibility
=============
**Requisition audit log**: from the first save after the upgrade, the requisition audit log records the available products as one value instead of a snapshot per product. The first save of each existing requisition after the upgrade is slower once, while the audit log records the change of format.

All other changes to OpenLMIS 3.x remain backwards-compatible. Any changes to data or schemas are accompanied by automated migrations from previous versions back to version 3.0.1.

All Changes by Component
========================
Version 3.20.1 of the Reference Distribution contains updated versions of the components listed below. The Reference Distribution bundles these components together using Docker to create a complete OpenLMIS instance. Each component has its own public GitHub repository (source code) and DockerHub repository (release image). The Reference Distribution and components are versioned independently.

- **BE Components**:
    - **Fulfillment Service 9.4.1** - `Fulfillment CHANGELOG <https://github.com/OpenLMIS/openlmis-fulfillment/blob/rel-9.4.1/CHANGELOG.md>`_
    - **Requisition Service 8.7.1** - `Requisition CHANGELOG <https://github.com/OpenLMIS/openlmis-requisition/blob/rel-8.7.1/CHANGELOG.md>`_
    - **Stock Management 5.4.1** - `Stock Management CHANGELOG <https://github.com/OpenLMIS/openlmis-stockmanagement/blob/rel-5.4.1/CHANGELOG.md>`_

Components with No Changes
==========================
- **BE Components**:
    - **Auth Service 4.5.0** - `Auth CHANGELOG <https://github.com/OpenLMIS/openlmis-auth/blob/rel-4.5.0/CHANGELOG.md>`_
    - **CCE Service 1.5.0** - `CCE CHANGELOG <https://github.com/OpenLMIS/openlmis-cce/blob/rel-1.5.0/CHANGELOG.md>`_
    - **Notification Service 4.5.0** - `Notification CHANGELOG <https://github.com/OpenLMIS/openlmis-notification/blob/rel-4.5.0/CHANGELOG.md>`_
    - **Hapifhir 2.2.0** - `Hapifhir CHANGELOG <https://github.com/OpenLMIS/openlmis-hapifhir/blob/rel-2.2.0/CHANGELOG.md>`_
    - **BUQ 1.2.0** - `BUQ CHANGELOG <https://github.com/OpenLMIS/openlmis-buq/blob/rel-1.2.0/CHANGELOG.md>`_
    - **Dhis2 Integration 1.2.0** - `Dhis2 Integration CHANGELOG <https://github.com/OpenLMIS/openlmis-dhis2-integration/blob/rel-1.2.0/CHANGELOG.md>`_
    - **Diagnostics 1.1.5** - `Diagnostics CHANGELOG <https://github.com/OpenLMIS/openlmis-diagnostics/blob/rel-1.1.5/CHANGELOG.md>`_
    - **Reference Data Service 15.7.0** - `ReferenceData CHANGELOG <https://github.com/OpenLMIS/openlmis-referencedata/blob/rel-15.7.0/CHANGELOG.md>`_
    - **Report Service 1.6.0** - `Report CHANGELOG <https://github.com/OpenLMIS/openlmis-report/blob/rel-1.6.0/CHANGELOG.md>`_
    - **One Network Integration Service 0.0.2** - `One Network Integration Service CHANGELOG <https://github.com/OpenLMIS/one-network-integration-service/blob/rel-0.0.2/CHANGELOG.md>`_

- **UI Components and Services**:
    - **Reference UI 5.2.15** - `The Reference UI <https://github.com/OpenLMIS/openlmis-reference-ui/tree/rel-5.2.15>`_
    - **Reference Data-UI 5.7.0** - `ReferenceData-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-referencedata-ui/blob/rel-5.7.0/CHANGELOG.md>`_
    - **Fulfillment-UI 6.2.0** - `Fulfillment-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-fulfillment-ui/blob/rel-6.2.0/CHANGELOG.md>`_
    - **Requisition-UI 7.1.0** - `Requisition-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-requisition-ui/blob/rel-7.1.0/CHANGELOG.md>`_
    - **Stock Management-UI 2.2.0** - `Stock Management-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-stockmanagement-ui/blob/rel-2.2.0/CHANGELOG.md>`_
    - **UI-Components 7.3.0** - `UI-Components CHANGELOG <https://github.com/OpenLMIS/openlmis-ui-components/blob/rel-7.3.0/CHANGELOG.md>`_
    - **Dev UI 9.1.0** - `Dev-UI CHANGELOG <https://github.com/OpenLMIS/dev-ui/blob/rel-9.1.0/CHANGELOG.md>`_
    - **Auth-UI 6.2.19** - `Auth-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-auth-ui/blob/rel-6.2.19/CHANGELOG.md>`_
    - **UI-Layout 5.2.11** - `UI-Layout CHANGELOG <https://github.com/OpenLMIS/openlmis-ui-layout/blob/rel-5.2.11/CHANGELOG.md>`_
    - **Report-UI 5.3.0** - `Report-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-report-ui/blob/rel-5.3.0/CHANGELOG.md>`_
    - **CCE-UI 1.1.12** - `CCE-UI CHANGELOG <https://github.com/OpenLMIS/openlmis-cce-ui/blob/rel-1.1.12/CHANGELOG.md>`_
    - **Offline UI 1.0.9** - `Offline UI CHANGELOG <https://github.com/OpenLMIS/openlmis-offline-ui/blob/rel-1.0.9/CHANGELOG.md>`_
    - **One Network Integration UI 0.0.7** - `One Network Integration UI CHANGELOG <https://github.com/OpenLMIS/one-network-integration-ui/blob/v0.0.7/CHANGELOG.md>`_

- **Analytics**:
    - **OpenLMIS Reporting 1.0.0** - `OpenLMIS Reporting CHANGELOG <https://github.com/OpenLMIS/openlmis-reporting/blob/rel-1.0.0/CHANGELOG.md>`_

- **Infrastructure**:
    - **Nginx v7.1**, **PostgreSQL 14-debezium**, **Rsyslog 3** and **Consul 1.15** are unchanged.

Upgrading from Older Versions
=============================
If you are upgrading from a version older than 3.20.0, review the `3.20.0 Release Notes <https://docs.openlmis.org/en/latest/releases/openlmis-ref-distro-v3.20.0.html>`_ first, in particular the stock management migration and the ``DATABASE_URL`` requirement.

Upgrading from 3.20.0 to 3.20.1 requires no manual steps.

Test Coverage
=============
The changes in OpenLMIS 3.20.1 were deployed to the UAT environment and tested manually, including full stock-based and non stock-based requisition cycles, emergency requisitions, order CSV export and the FTP order transfer. The results were also compared with 3.20.0 on identical data, with no regressions found.

Download or View on GitHub
==========================
`OpenLMIS Reference Distribution 3.20.1
<https://github.com/OpenLMIS/openlmis-ref-distro/releases/tag/v3.20.1>`_

Known Issues
============
- Batch Approval: Packs/Doses are not supported in the batch approve requisition view.
- POD Compatibility: Packs/Doses are not supported in the POD creation.
- Order Fulfillment: Quantity shipped must always be provided in packs.
- Lot creation during stock events: a lot created while processing a receive or physical inventory event is not removed if the event then fails validation. It remains as an active lot without stock, and a resubmitted event reuses it.

Other bugs are collected in Jira for troubleshooting, analysis, and resolution on an ongoing basis. See `OpenLMIS Bugs <https://openlmis.atlassian.net/issues/?jql=type%20%3D%20Bug%20and%20project%20%3D%20%22OpenLMIS%20General%22%20AND%20status%20not%20in%20(Done%2CCanceled)>`_ for the current list of known bugs.

To report a bug, see `Reporting Bugs
<https://docs.openlmis.org/en/latest/contribute/contributionGuide.html#reporting-bugs>`_.

Contributions
=============
Many organizations and individuals around the world have contributed to OpenLMIS version 3 by serving on committees (Governance, Product, and Technical), requesting improvements, suggesting features, and writing code and documentation. Please visit our GitHub repositories to see the list of individual contributors to the OpenLMIS codebase. If anyone who contributed on GitHub is missing, please contact the Community Manager. Technical development of OpenLMIS is conducted by `SolDevelo <https://soldevelo.com>`_.

Further Resources
=================
Please see the Implementer Toolkit on the `OpenLMIS website <https://openlmis.org/get-started/implementer-toolkit/>`_ to learn more about best practices in implementing OpenLMIS. Also, learn more about the `OpenLMIS Community <https://openlmis.org/about/community/>`_ and how to get involved!
