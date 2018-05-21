############################
Non-functional Requirements
############################

Note:  WIP

Non-functional requirements (NFR) are those that impose constraints on the
design of OpenLMIS.  The goal of this document is to ensure the OpenLMIS
community has a consistent understanding of how these requirements are
discovered, defined and prioritized.

Process
--------

NFR as stated previously impose specific constraints on OpenLMIS.  These
constraints if defined without careful consideration may result in significant
increases to level of effort and a focus taken away from other areas.

When defining NFR we need to:

- Be domain focused:  some NFR will be defined in terms of the problem domain.
  e.g. For a Report and Requisition, we can identify the number of Reports and
  Requisitions the system will handle.  We typically might consider the # of
  concurrent Requisition's being submitted, the total number the system might
  process a day/week/year/etc.
- Be context aware:  NFR often need to be aware of the context they're being
  defined in.  For OpenLMIS this context might be the user persona combined with
  the problem domain.  So for our Requisition's example above, we might focus on
  the NFR of the # number Requisitions that a Zonal Warehouse Manager might need
  to process day/week/year/etc.  Further we would do well to add to the context
  what sort of network connection and device characteristics the user persona
  might typically be expected to have.  In this case we'd add that the Zonal
  Warehouse Manager might be expected to have a recent Laptop with 90 % 3G
  Internet availability, whereas a Community Health Worker might only expect to
  have 30 % 2G Internet availability and use a Android phone 2-3 generations
  old.
- Focus on defining NFR quantitatively, and testing automatically.  e.g. we
  could define response time needs to be < 500ms, and therefore we can
  automatically test that our response time meets this requirement.
- Bring the user experience and technical leaders together.  A classic example
  of only involving one group is to ask stakeholders "how often should the
  application be available?" to which they'd rightly respond "all the time".
  This 100% availability metric can be exceptionally difficult to obtain and
  leads to costly investments when in reality some gaps in availability are
  likely preferred considering the costs.  By bringing these groups together
  we'll get a more reasonable requirement:  The application must be available
  90% of the time, and the 10% of the time it is not should be scheduled for
  non-work hours and days in Central Africa Timezone.

In practice for the OpenLMIS community, the two communities that need to agree
on NFR are the Product Committee and the Technical Committee.


Auditability
-------------

All concepts in OpenLMIS should support an audit log which can track every
state change with:

- A time-stamp including timezone of when the change occurred.
- A unique identifier for the user account that made the change.  Or if the
  change was not directly caused by a user that should be clear.
- The before and after states of the change.


Performance
------------

For performance we focus on these measures:

- Response time (<= 500ms)
- Concurrency
- Size (objects or rows) of stored data.
- Size of working data.  e.g. off-line or in-process stored locally and / or
  that a user works with at any given time.
- Render time
- Network latency (typically characterized by 2G or 3G).
- CPU (typically characterized by a fraction of a "mordern" processor).

And we focus on load testing over stress or other types of testing (e.g. stress
or endurance).  For more on how we test, see `Performance Testing`_ and 
`Functional Testing`_.

Availability
-------------

- Offline
- # of 9s

Configuration Management
-------------------------

Security
---------

Data integrity
---------------
- ACID

Recoverability
---------------
- Drafts
- Backups
- Distributed devices

Interoperability
-----------------

- mCSD w/ FHIR
- GS1 GTIN and GLN
- GS1 EDI
- OAuth2
- REST w/ JSON

Usability
---------

- Screen size
- Browser
- Affordances

Todo
-----

#. Clarify concurrency in Performance.
#. Clarify network and CPU in performance - currently not given in highly 
   reproducible terms.
#. Clarify render time in performance
#. Clarify the 2 size of data in Performance - how will we define it here across
   domains?  Or use links?
#. Move functional testing into RTD.
#. Fill in Interoperability
#. Fill in Data integrity
#. Fill in etc...


.. _Performance Testing: performance.html
.. _Functional Testing: https://github.com/OpenLMIS/openlmis-functional-tests/blob/master/README.md