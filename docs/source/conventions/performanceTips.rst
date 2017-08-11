=================
Performance Tips
=================

Testing and Profiling
======================

Knowing where to invest time and resources into optimization is always the first step.  This 
document will briefly cover the highlights of two of them, and then dive into specific strategies
for increasing performance.

To see how to test HTTP based services see `performance testing`_.

Profiling
----------

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

Using SLF4J Profiler in Java code is as simple as:

.. code-block:: Java

  Profiler profiler = new Profiler("GET_ORDERABLES_SEARCH");
  profiler.setLogger(XLOGGER); // can be SLF4J Logger or XLogger

  profiler.start("CHECK_ADMIN_RIGHT");
  rightService.checkAdminRight(ORDERABLES_MANAGE);

  profiler.start("ORDERABLE_SERVICE_SEARCH");
  Page<Orderable> orderablesPage = orderableService.searchOrderables(queryParams, pageable);

  profiler.start("ORDERABLE_PAGINATION");
  Page<OrderableDto> page = Pagination.getPage(OrderableDto.newInstance(
      orderablesPage.getContent()),
      pageable,
      orderablesPage.getTotalElements());

  profiler.stop().log();

This will generate log statements that look like the following:

.. code-block::
  
  2017-07-24T19:49:45+00:00 e2f424e5b617 [nio-8080-exec-5] DEBUG 
  org.openlmis.referencedata.web.OrderableController #012+ Profiler 
  [GET_ORDERABLES_SEARCH]#012|
  -- elapsed time [CHECK_ADMIN_RIGHT] 1173.997 milliseconds.#012|
  -- elapsed time [ORDERABLE_SERVICE_SEARCH] 199.251 milliseconds.#012|
  -- elapsed time [ORDERABLE_PAGINATION] 0.255 milliseconds.#012|
  -- Total [GET_ORDERABLES_SEARCH] 1373.511 milliseconds. 

Placed in the Controller for this HTTP operation we can tell:

#. Most of the time for this innvocation is spent checking if the user has the right: more than 
   1 second.
#. Fetching the entities from the database took about 14% of the time
#. Turning them into DTOs used up *less* than a millisecond.
#. We'd have to look at the Service's access log to find where additional latency is introduced that
   we can't meassure here:  serialization, IO overhead, Spring Boot magic, etc

This lets us know easily that improving the performance of the permission check might be well worth
the effort. Since this information is in the logs we can also monitor and graph the performance of 
the data retrievel latency in real-time with a well crafted search on our logs.

SLF4J Profile Conventions
^^^^^^^^^^^^^^^^^^^^^^^^^^

- Use the Profiler in Controller methods for code that's released to production.  While in
  development you can use a Profiler anywhere you wish, it tends to clutter the code and the logs
  longer term.  A few we'll placed Profiler.start() statements, left in the Controller however,
  can pay dividends longer term when performance issues need to be diagnosed in implementations.
- Prepend the HTTP operation to the beginning of the name.  So :code:`GET_ORDERABLES_SEARCH` and
  not `ORDERABLES_SEARCH`.
- Prefer all upper-case snake_case.  e.g. :code:`GET_ORDERABLES_SEARCH` never 
  :code:`getOrderablesSearch`.
- Be descriptive and strategic in your Profiler.start() names and locations.  E.g. use a new 
  Profiler.start() before a block/method that does something unlike the code before it:  checking
  permissions, retrieving data, performing an update, returning a result.  Use names that are clear
  for those who'll be reading the logs in production systems years from now.

Logging
========

In our service-architecture we have many different components where latency can be introduced and 
therefore logs we need to examine when diagnosing where time is being spent:

From the top of the stack down:

#. The Amazon ELB:  typically the first place a request arrives, there is usually a very minor
   bit of latency incurred here.  ELB logging if turned on is typically logged to S3.
#. Nginx reverse-proxy:  Nginx is *the* place for finding HTTP operations.  Requests from clients
   are routed through Nginx to upstream (aka backend) Services, and from service to service.  The
   `Nginx access log`_ is the first place to see how long it took to process the request and how much
   time was spent in an upstream service performing the operation.
#. Service HTTP access log: these (tomcat) access logs are not always prominent however they can
   be turned on to give an idea of how much time the Service's HTTP server spent serving the request
   as opposed to how much time was spent transmitting the data.  With good network connectivity
   between Nginx and backend Service (typically localhost), this is rarely an issue, though it can
   sometimes uncover hidden issues.
#. Service's Profiler statements:  these logging statements from Java code are treated like all
   other Java logging statements and are channeled through our centralised :code:`Rsyslog` container 
   to be aggregated and written to disk (and later picked up by log monitoring service - Scalyr).
#. Database: queries take time, transactions can block, etc.  Database logs can uncover both the 
   time specific queries take as well as the actual SQL that's being run in the database.  These 
   logs are typically sourced and monitored through the RDS service (and Scalyr).

Lets look at an example of a call seen by Nginx and the Profiler.

Service's Profiler (again):

.. code-block::
  
  2017-07-24T19:49:45+00:00 e2f424e5b617 [nio-8080-exec-5] DEBUG 
  org.openlmis.referencedata.web.OrderableController #012+ Profiler 
  [GET_ORDERABLES_SEARCH]#012|
  -- elapsed time [CHECK_ADMIN_RIGHT] 1173.997 milliseconds.#012|
  -- elapsed time [ORDERABLE_SERVICE_SEARCH] 199.251 milliseconds.#012|
  -- elapsed time [ORDERABLE_PAGINATION] 0.255 milliseconds.#012|
  -- Total [GET_ORDERABLES_SEARCH] 1373.511 milliseconds. 

Nginx access log:

.. code-block::

  10.0.0.238 - - [24/Jul/2017:19:49:45 +0000] "POST /api/orderables/search HTTP/1.1" 200 18455 "-" "Java/1.8.0_92" 1.401 0.000 1.401 1.401 . 

Read the `Nginx access log`_ format for the details of what these numbers mean.  What we can tell
comparing these two is that:

- the total time to the user (just for this operation, not a web-page) was 1.4 seconds.
- All of that time was spent by the Reference Data service (because response time == upstream time).
- There is 28ms of latency not accounted for in our Profiler.  It could be time spent in 
  serialization of Java objects, Spring Boot overhead, tomcat overhead, network overhead (e.g. 
  we were suffering from a 200ms delay due to a TCP configuration being off previously).
- Our user must be on a fast network connection, as Nginx spent the same time serving the response
  as it did getting the results from the upstream server. (a bit oversimplified).
- Approx 18.5KB we're returned in this Orderables Search.

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

The important part here is the use of the repositories :code:`existsByCode(...)`, which is a 
`Spring Data projection`_. This will avoid pulling the row, avoid turning a row into a Java object, 
and in general can save upwards of 100ms as well as the extra memory overhead.  If the column is 
indexed (and well indexed), the database may even avoid a trip to disk, which typically can bring 
this check in under a millisecond.

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
.. _Nginx access log: https://github.com/OpenLMIS/openlmis-nginx#nginx-access-log-format
.. _pagination API conventions: https://github.com/OpenLMIS/openlmis-template-service/blob/master/STYLE-GUIDE.md#pagination
.. _Spring Data Pageable: 
.. _database paging pattern: https://groups.google.com/d/msg/openlmis-dev/WniSS9ZIdY4/B7vNXcchBgAJ
.. _Spring Data projection: https://docs.spring.io/spring-data/rest/docs/current/reference/html/#projections-excerpts.projections 
.. _Orderable search: https://github.com/OpenLMIS/openlmis-referencedata/blob/8de4c200aaf7ccb3dc1e450eb606185a953a8448/src/main/java/org/openlmis/referencedata/web/OrderableController.java#L157

