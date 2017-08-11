=================
Performance Tips
=================

Testing and Profiling
======================

Knowing where to invest time and resources into optimization is always the first step.  This 
document will briefly cover the highlights of two of them, and then dive into specific strategies
for increasing performance.

To see how to test HTTP based services see `performance testing`_.

After we've identified that a HTTP operation is slow, there are two simple tools that can help us
in understanding why:

- `SLF4J Profiler`_: useful to print latency meassurements to our log.  It's cheap and a bit dirty,
  though highly-effective and it works in remote production environments in real-world scenarios.
- `VisualVM`_: perhaps the most well known Java profiling tool can give great information about
  what the code is doing, however since it needs to connect directly to the JVM running that
  Service's code, it's better suited for local development environments rather than debugging
  production servers.

The usefulness of basic profiling metrics from production environments can't be understated.
Performance issues rarely occur in local development environments and the people most impacted by
slow performance are people using production systems.  Just as our performance tests operate against
a deployment topology that tries to match what most of our customers use, so to must we know about
how that code is performing in real-usage.  For these reasons this document will focus more on 
logging performance metrics with SLF4J Profiler rather than VisualVM.


- intro with how to identify server calls that are a problem (testing) and
  how to find bottlenecks
- demo SLF4J Profiler, give pattern for profiler names and where to place them
- point to JVisualVM
- point out Profiler's can help in diagnosing production systems (e.g. the N+1
  exhibited in User's )

Logging
========
- example of Profiler in log, compared to Nginx logs
  (response time, upstream times)
- ELB?  Scalyr?

RESTful representations and the JPA to avoid
=============================================

Avoid loading entities unnecessarily
-------------------------------------

Don't load an entity object if you don't have to; use Spring Data JPA
:code:`exists()` instead. A good example of this is in the RightService for
Reference Data. The :code:`checkAdminRight()` checks for a user when it receives
a user-based client token. If the user is checking their own information, they
only need to verify the existence of the user, instead of getting the full User
info (using findOne()). Spring Data JPA's :code:`CrudRepository` supports this
through the method :code:`exists()`.

In Spring Data JPA 1.11's (shipped in Spring Boot 1.5+) `CrudRepository`
ships with :code:`exists()` support for more than just the primary key column.

For example, take this bit of code that was found when searching for Orderables
by a Program's code:

.. code-block:: Java

    // find program if given
    Program program = null;
    if (programCode != null) {
      program = programRepository.findByCode(Code.code(programCode));
      if (program == null) {
        throw new ValidationMessageException(ProgramMessageKeys.ERROR_NOT_FOUND);
      }
    }

This requires a trip to the database, which will need to pull the entire Program
row, back to the Service which will then turn it into a Java object, which then,
checks if the Program is null.  Using an exists check, we can write code such
as:

.. code-block:: Java

  // find program if given
  Code workingProgramCode = Code.code(programCode);
  if ( false == workingProgramCode.isBlank()
      && false == programRepository.existsByCode(workingProgramCode) ) {
    throw new ValidationMessageException(ProgramMessageKeys.ERROR_NOT_FOUND);
  }

The important part here is the use of the repositories :code:`existsByCode(...)`, which is a Spring
Data _projection. This will avoid pulling the row, avoid turning a row into a Java object, and in
general can save upwards of 100ms as well as the extra memory overhead.  If the
column is indexed (and well indexed), the database may even avoid a trip to
disk, which typically can bring this check in under a millisecond.

Use Database Paging
--------------------

Database paging is vastly more performant and efficient than Java paging or not paging at all.
How much more?  Before the Orderable's search resource was paged in the database, it was paged in
Java.  In Java pulling a page of only 10 Orderables out of a set of 10k Orderables took around 20
seconds, after, this same operation took only 2 seconds (10x more performant) and of that 95% of
those 2 seconds are spent in an unrelated permission check.

The `database paging pattern`_ was established and as of this writing is not well enough adopted.
Remember when paging to:

#. Follow the `pagination API conventions`_.
#. Use `Spring Data Pageable`_ all the way to the query.
#. `Spring Data projection`_ makes this easy (more so in 1.11+). So code like this just works:
    
    .. code-block:: Java
    
      @Query("SELECT o FROM Orderable o WHERE o.id in ?1")
      Page<Orderable> findAllById(Iterable<UUID> ids, Pageable pageable);

#. If it's a Query, you'll need to run 2 queries:  one for a :code:`count()` and one for the (sub) 
   list.
#. If you're a client, *use* the query parameters to page the results - otherwise our convention
   will be to return the largest page we can to you, which is slower.

Follow the pattern in `Orderable search`_.


eager / lazy loading
---------------------

WIP - favor the common case
  (this needs to talk about our biggest mistake to date: overly deep resource
  representations - bad for JPA, bad for network, bad for caching)

N+1 loading
------------
WIP

database joins are expensive
-----------------------------
WIP

primary keys, indexes, and foreign keys
----------------------------------------
WIP(prefer primary key, index and what are good/bad ones, foreign keys
  aren't indexed)

Flatten complex structures
--------------------------
We should take complex structures that do not change often, flattening and
storing them in the database. This would create a higher expense in writes, but
improve performance in reads. Since reads would be more common than writes, the
trade-off is beneficial overall.

A good example here are the concept of permission strings. The role-based
access control (RBAC) for users is complex, with users being assigned to roles
potentially by program, facility, both, or neither. However, all of the rights
that a user has can be represented by a set of permission strings, with
complexity represented in different string formats. Formats as follows:

- RightName - for general rights
- RightName|FacilityUUID - for fulfillment rights
- RightName|FacilityUUID|ProgramUUID - for supervision rights

The different parts of the permission are in different parts of the string, and
each part is delimited with a delimiter (pipe symbol in this case).

These strings, or each part of these strings, are saved as rows in a separate
table and retrieved directly. This dramatically improves read performance,
since we avoid retrieving the complex RBAC hierarchy and manipulating it in the
Java code.

See https://groups.google.com/d/msg/openlmis-dev/wKqgpJ2RgBA/uppxJGJiAwAJ for
further discussion about permission strings.

HTTP Cache
==========
- list out etag, if-none-match
- example of where server cycles are still expended - permission strings
- future example of where server cycles are avoided (etag stored/cached or
  audit based)


.. _Performance Testing: performanceTesting
.. _SLF4J Profiler: https://www.slf4j.org/extensions.html#profiler
.. _VisualVM: https://visualvm.github.io/
.. _pagination API conventions: https://github.com/OpenLMIS/openlmis-template-service/blob/master/STYLE-GUIDE.md#pagination
.. _Spring Data Pageable: 
.. _database paging pattern: https://groups.google.com/d/msg/openlmis-dev/WniSS9ZIdY4/B7vNXcchBgAJ
.. _Spring Data projection: https://docs.spring.io/spring-data/rest/docs/current/reference/html/#projections-excerpts.projections 
.. _Orderable search: https://github.com/OpenLMIS/openlmis-referencedata/blob/8de4c200aaf7ccb3dc1e450eb606185a953a8448/src/main/java/org/openlmis/referencedata/web/OrderableController.java#L157

