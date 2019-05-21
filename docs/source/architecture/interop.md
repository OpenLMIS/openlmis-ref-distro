# Interoperability

No one IT system can fully manage a supply chain, or a health system, in its
entirety.  This fact is a core design intention behind OpenLMIS' eager approach 
to working with other IT systems through established [open standards][]. Since 
OpenLMIS is web-based, has a supply chain focus, and originated in the health 
space the open standards that OpenLMIS uses also come from those spaces.

This document will cover specific standards and profiles that are in use while 
the [General Interoperability Approach][] document covers more on the
reasoning behind some of these choices in regards to enterprise integration.

[open standards]: https://opensource.com/resources/what-are-open-standards
[General Interoperability Approach]: https://docs.google.com/document/d/1AJhbWa6RKbEf5eRwGY1pNlUVc8lpODeEZCtUq5Q9zik/edit?usp=sharing

### Web

* REST APIs over HTTP w/ JSON preferred
* Authentication is delegated to OAuth2 with bearer tokens
* Unique identifiers are [UUID][]
* Datetimes in [RFC 3339][]
* Language tags in [ISO 639][]
* [UTF-8] encoding as default

[UUID]: https://en.wikipedia.org/wiki/Universally_unique_identifier
[RFC 3339]: https://tools.ietf.org/html/rfc3339
[ISO 639]: https://www.iso.org/iso-639-language-codes.html
[UTF-8]: https://en.wikipedia.org/wiki/UTF-8

### Supply Chain

* [Product Model][] leverages lessons learned from [GS1][] and the 
  [BI&A Logical Model][]
* Configurable file exchange (FTP/AS3) for exchanging Orders and Shipments with 
  Enterprise Resource Planning (ERP) / Warehouse Management Systems (WMS)
* GS1 identifiers supported on products with preference given to GS1 
  identifiers, message formats and event transactions where GS1 items are in 
  use. (expanding)
* Support for EDI (ANSI x12 / EDIFACT) in exchanging inventory reports (planned)

[Product Model]: https://openlmis.atlassian.net/wiki/x/PAASB
[BI&A Logical Model]: https://wiki.digitalsquare.io/images/d/d0/Logical_Reference_Model.pdf
[GS1]: https://www.gs1.org/


### Health

HL7's [FHIR][] for:

* [Location][] for facilities, geographic areas.  Planned support for 
  sub-facility
* [Device][] for Cold Chain Equipment
* [Measure][] & [MeasureReport][] for metrics and indicators.

[FHIR]: http://hl7.org/fhir/
[Location]: https://www.hl7.org/fhir/location.html 
[Device]: https://www.hl7.org/fhir/device.html
[Measure]: https://www.hl7.org/fhir/measure.html
[MeasureReport]: https://www.hl7.org/fhir/measurereport.html

## Profiles & Use Cases

Open standards give us most of what we need to start integrating systems,
however it can still be useful to refer to standard profiles and/or use
cases that use the standards to achieve a specific purpose.

### Note on sources of truth and derived definitions

When interoperating or integrating with another system it's important to take
a moment and determine which systems own a particular set of data, and which
systems need to know about that data, and potentially add to it.

For this reason we'll be using two terms in the following sections:

* Source of Truth (aka Master Data):  Is a source, often an IT system though it
  could be something such as a shared spreadsheet, that defines the one 
  canonical definition of some _thing_.  For some entities (such as a Product),
  there may be many sources of truth for specific aspects of that entity.  It's
  important to note however that no two or more sources of truth may try to 
  define the same aspect of the entity.
* Derived data:  Is data which comes from a source of truth.  It may enhance/add
  to the definition that comes from the source of truth.  e.g. a Master Facility
  List (MFR) may be a source of truth that defines the names and locations of 
  all the facilities.  In OpenLMIS the Facilities we have would be derived from 
  the MFR, and additionally we might enrich our derived definition with 
  information such as how it fits into the supply chain or whom in OpenLMIS is
  assigned to it.

A few examples of where OpenLMIS expects to be a source of truth:
* Re-supply requests and fulfillments that occur inside OpenLMIS
* A mapping of supply chain workflows and approval processes
* Cold chain equipment, where it's installed and functional status
* Stock cards and associated movements that occur in OpenLMIS

A few examples where OpenLMIS we hope to derive data from:
* Facilities, geographic and administrative areas
* Commodities, Items, Lots and Categorizations
* Cold chain equipment temperature and alerts thereof

### Defining Locations (geographic areas, facilities, store rooms, etc)

OpenLMIS needs to know about the Facilities and Geopgraphic Zones that are a
part of the supply chain to enable various re-supply workflows: hospitals, 
clinics, etc. While OpenLMIS needs this information, we believe that the 
process of uniquely identifying and assigning core attributes (e.g. name, 
address, etc) of these places works best when the information is curated 
outside of OpenLMIS, and then shared with OpenLMIS.

The core profile that describes the basic functioning of this is IHE's 
[mCSD profile][] of which OpenLMIS leverages [Location][] as the source of 
truth for:

* Name
* If it's a Geographic Zone or Facility
* Unique identifier
* Code(s)
* Hierarchy (e.g. Acme Clinic is in Maputo district which is in the Country Mozambique)
* Position (lat & long)

In OpenLMIS we support the ability for an implementation to "follow" a
[Registry][] that provides a complete list of Locations.  By following such a
registry OpenLMIS will allow the administrator to create Facilities and 
Geographic Zones that are based from the registry as a source of truth, and any
updates in the Registry will be reflected in OpenLMIS' derived definitions.

It's also possible for OpenLMIS to play the role of this registry which other
systems may subscribe to and follow when a more appropriate registry isn't
available, however we'd encourage implementations to take on the extra work
of implementing a more appropriate registry for this critical task.

[mCSD profile]: https://wiki.ihe.net/index.php/Mobile_Care_Services_Discovery_(mCSD)
[Registry]: https://ohie.org/facility-registry/

### Supply Chain Metrics & Indicators

OpenLMIS has a number of re-supply workflows that produce metrics and indicators
relating to the functioning of the supply chain.  These are made available
through the use of FHIR's Measure and MeassureReport:

* [Measure][]: Defines a metric/indicator (e.g. #days stocked out or supply 
  status)
* [MeasureReport][]: Contains the values for a Measure by [Location][] and a 
  period of time.

This usage is intended to comply with the (upcoming) IHE [mADX profile][].

By publishing indicators in this way, a connector (planned) can discover new
MeasureReport's as they are published/updated and move them to analytical
systems such as [DHIS2][].  More about this approach can be read in OpenLMIS'
[Interoperability w/ DHIS2][]

[Measure]: https://www.hl7.org/fhir/measure.html
[MeasureReport]: https://www.hl7.org/fhir/measurereport.html#MeasureReport
[mADX profile]: https://wiki.ihe.net/index.php/Mobile_Aggregate_Data_Exchange
[DHIS2]: http://dhis2.org
[Interoperability w/ DHIS2]: https://docs.google.com/document/d/19xysVDrfBuJcqTyDd7-j3zzOSnAU0WMf6OcmSFZ20eI/edit?usp=sharing

### Cold-chain Equipment & Remote Temperature Monitoring (RTM)

OpenLMIS defines a catalog of cold-chain equipment (e.g. refrigerator), which 
may be imported from [WHO's PQS][], and where that equipment is located.  This
registry of what equipment has been installed and where it is located is
available as a list of FHIR [Device][].

***
**NOTE** 

_OpenLMIS' acting as a registry in this case is done in-lieu of a more
appropriate source of truth for cold chain equipment installation and location. 
We'd be happy to learn if there's a more appropriate open, source of truth, 
system_.
***

OpenLMIS may also receive [status alerts][] about equipment functionality, which
is normally sourced from a Remote Temperature Monitoring (RTM) device, such as
Nexleaf's [ColdTrace][].

[WHO's PQS]: http://apps.who.int/immunization_standards/vaccine_quality/pqs_catalogue/
[status alerts]: http://build.openlmis.org/job/OpenLMIS-cce-pipeline/job/master/lastSuccessfulBuild/artifact/build/resources/main/api-definition.html#api_cceAlerts_put
[ColdTrace]: https://nexleaf.org/vaccines/