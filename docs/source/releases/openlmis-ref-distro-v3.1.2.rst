==============================
3.2.0 Release - 31 August 2017
==============================

Status: Stable
==============

3.2.0 is a stable release, and all users of `OpenLMIS version 3
<https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017>`_ are
encouraged to adopt it.

Release Notes
=============

The OpenLMIS Community is excited to announce the **3.2.0 release** of OpenLMIS!

This release represents another major milestone in the version 3 series, which is the result of a
software `re-architecture <https://openlmis.atlassian.net/wiki/display/OP/Re-Architecture>`_ that
allows more functionality to be shared among the community of OpenLMIS users.

3.2.0 includes a new **Cold Chain Equipment** (CCE) service and other improvements for Vaccine/EPI
programs. This represents the first milestone towards the `Vaccines MVP
<https://openlmis.atlassian.net/wiki/spaces/OP/pages/113144940/Vaccine+MVP>`_ feature set. 3.2.0
also contains more contributions from the **Malawi implementation**, a national implementation that
is now live on OpenLMIS version 3. The latest contributions include a new Batch Requisition View
feature as well as performance improvements.

After 3.2.0, there are further planned `milestone releases and patch releases
<http://docs.openlmis.org/en/latest/conventions/versioningReleasing.html>`_ that will continue
towards the vision of providing a full-featured electronic logistics management information system
(LMIS). Please reference the `Living Product Roadmap
<https://openlmis.atlassian.net/wiki/display/OP/Living+Product+Roadmap>`_ for the upcoming release
priorities. Patch releases will continue to include bug fixes, performance improvements, and pull
requests are welcomed.

Compatibility
-------------

All changes are backwards-compatible. Any changes to data include automated migrations from previous
versions back to 3.0.1. Any exceptions are identified in the Components sections below.

For background information on OpenLMIS version 3's new micro-service architecture,
extensions/customizations, and upgrade paths for OpenLMIS versions 1 and 2, see the `3.0.0 Release
<https://openlmis.atlassian.net/wiki/spaces/OP/pages/88670325/3.0.0+Release+-+1+March+2017>`_.

Download or View on GitHub
--------------------------

`OpenLMIS Reference Distribution 3.2.0
<https://github.com/OpenLMIS/openlmis-ref-distro/releases/tag/v3.2.0>`_

New Features
============

This is a new section to flag all the new features specifically. Hopefully many of these are
configurable or have a toggle so new features will not negatively impact existing implementations.

Changes to Existing Functionality
=================================

This is a new section to flag any changes to existing functionality. This can be UI or API changes.
Anything that has impacts for users/training or existing implementations/integrations.

All Changes by Component
========================

This is the full list of all changes, linked to ticket numbers, organized by component.

Reference UI 5.x.y
------------------

The reference UI bundles the following UI components together.

auth-ui 5.y.z
~~~~~~~~~~~~~

(insert list of changes and link to CHANGELOG)

fulfillment-ui 5.y.z
~~~~~~~~~~~~~~~~~~~~

(insert list of changes and link to CHANGELOG)

referencedata-ui 5.y.z
~~~~~~~~~~~~~~~~~~~~~~

(insert list of changes and link to CHANGELOG)

report-ui 5.y.z
~~~~~~~~~~~~~~~

(insert list of changes and link to CHANGELOG)

requisition-ui 5.y.z
~~~~~~~~~~~~~~~~~~~~

(insert list of changes and link to CHANGELOG)

stockmanagement-ui 1.0.0-beta ???
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

(insert list of changes and link to CHANGELOG)

ui-components 5.y.z
~~~~~~~~~~~~~~~~~~~

(insert list of changes and link to CHANGELOG)

ui-layout:5.y.z
~~~~~~~~~~~~~~~

(insert list of changes and link to CHANGELOG)

Requisition Service a.b.c
-------------------------

Requisition content goes here.

Fulfillment Service 4.t.s
-------------------------

Fulfillment content goes here.

Stock Management 1.0.0-beta???
------------------------------

Stock content goes here. Need to decide if we are finally releasing 1.0.0 of Stock Management.

Reference Data Service d.e.f
----------------------------

RefData content goes here.

Auth Service 3.g.h
------------------

Auth content goes here.

Notification Service 3.f.g
--------------------------

Notification content goes here.

Components with No Changes
==========================

Other tooling components have not changed, including: the `logging service
<https://github.com/OpenLMIS/openlmis-rsyslog>`_, the tailored docker-ized distribution of `nginx
<https://github.com/OpenLMIS/openlmis-nginx>`_ and `postgres
<https://github.com/OpenLMIS/postgres>`_, and a library for shared Java code called `service-util
<https://github.com/OpenLMIS/openlmis-service-util>`_.

Contributions
=============

Need to write. Perhaps link to the slides or video recording that was shared with PC.

Thanks to the Malawi implementation team who has contributed a number of pull requests to add
functionality and customization in ways that have global shared benefit.

Maybe we should take the time to go to all GitHub repos to pull a list of all names of all
contributors again, or at least since 3.1.0.

Further Resources
=================

View all `JIRA Tickets in 3.2.0 <https://openlmis.atlassian.net/issues/?jql=statusCategory%20%3D%20d
one%20AND%20project%20%3D%2011100%20AND%20fixVersion%20%3D%203.2%20ORDER%20BY%20type%20ASC%2C%20prio
rity%20DESC%2C%20key%20ASC>`_.

Learn more about the `OpenLMIS Community <http://openlmis.org/about/community/>`_ and how to get
involved!
