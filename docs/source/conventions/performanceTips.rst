=================
Performance Tips
=================

Testing and Profiling
======================

Knowing where to invest time and resources into optimization is always the first step.  This 
document will briefly cover the highlights of two tools which help us determine where we should
invest our time, and then we'll dive into specific strategies for making our performance better.

To see how to test HTTP based services see :doc:`performance`.

Profiling
----------

After we've identified that a HTTP operation is slow, there are two simple tools that can help us
in understanding why:

- `SLF4J Profiler`_: useful in printing latency meassurements to our log.  It's cheap and a bit 
  inaccurate, though quite effective and it works in all production environments.
- `VisualVM`_: perhaps the most well known Java profiling tool can give great information about
  what the code is doing, however since it needs to connect directly to the JVM running that
  Service's code, it's better suited for local development environments rather than debugging
  production servers.

The usefulness of basic profiling metrics from production environments can't be understated.
Performance issues rarely occur in local development environments and the people most impacted by
slow performance are people using production systems.  Just as our performance tests operate against
a :doc:`../deployment/topology` that tries to match what most of our customers use, so to is it 
useful to know how that code is performing in customer implementations.  For these reasons this 
document will focus more on logging performance metrics with SLF4J Profiler rather than VisualVM.

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

.. code-block:: none
  
  2017-07-24T19:49:45+00:00 e2f424e5b617 [nio-8080-exec-5] DEBUG 
  org.openlmis.referencedata.web.OrderableController #012+ Profiler 
  [GET_ORDERABLES_SEARCH]#012|
  -- elapsed time [CHECK_ADMIN_RIGHT] 1173.997 milliseconds.#012|
  -- elapsed time [ORDERABLE_SERVICE_SEARCH] 199.251 milliseconds.#012|
  -- elapsed time [ORDERABLE_PAGINATION] 0.255 milliseconds.#012|
  -- Total [GET_ORDERABLES_SEARCH] 1373.511 milliseconds. 

Placed in the Controller for this HTTP operation we can tell:

#. Most of the time for this innvocation is spent checking if the user has a right: more than 
   1 second.
#. Fetching the entities from the database took about 14% of the time
#. Turning them into DTOs used up *less* than a millisecond.
#. We'd have to look at the Service's access log to find where additional latency is introduced that
   we can't meassure here:  serialization, IO overhead, Spring Boot magic, etc

This easily lets us know that improving the performance of the permission check might be well worth
the effort. Since this information is in the logs we can also monitor and graph the performance of 
the data retrievel latency (ORDERABLE_SERVICE_SEARCH) in real-time with a well crafted search on our 
logs.

SLF4J Profile Conventions
^^^^^^^^^^^^^^^^^^^^^^^^^^

- Use the Profiler in Controller methods for code that's released to production.  While in
  development you can use a Profiler anywhere you wish, it tends to clutter the code and the logs
  longer term.  A few well placed Profiler.start() statements, left in the Controller however,
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

.. code-block:: none
  
  2017-07-24T19:49:45+00:00 e2f424e5b617 [nio-8080-exec-5] DEBUG 
  org.openlmis.referencedata.web.OrderableController #012+ Profiler 
  [GET_ORDERABLES_SEARCH]#012|
  -- elapsed time [CHECK_ADMIN_RIGHT] 1173.997 milliseconds.#012|
  -- elapsed time [ORDERABLE_SERVICE_SEARCH] 199.251 milliseconds.#012|
  -- elapsed time [ORDERABLE_PAGINATION] 0.255 milliseconds.#012|
  -- Total [GET_ORDERABLES_SEARCH] 1373.511 milliseconds. 

Nginx access log:

.. code-block:: none

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
- Approx 18.5KB was returned in this Orderables Search.

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
ships with :code:`exists()` support for more than just the primary key column using Projections.

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
entity, back to the Service which will then turn it into a Java object... which will finally
do what we actually wanted and check if the Program is null.  Using an exists check, we can write 
code such as:

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

Make sure that the returning object is as minimal as possible. Sometimes an endpoint returns
the whole representation while a basic representation is enough. Some of the properties included in the full DTO are
unnecessary in the given endpoint and not included in the basic version so we can simply use
the second one. You can also use expand pattern to minimize the entity size in the response.

Expand pattern
---------------

Using ObjectReference and expand pattern we can reduce the size of a response but with
the opportunity to include the whole object instead of references when it is necessary.
We can specify properties that need to be expanded and the rest of them will be object references.
The example of use this pattern:

.. code-block:: Java

  @RequestMapping(value = "/orders/{id}", method = RequestMethod.GET)
  @ResponseBody
  public OrderDto getOrder(@PathVariable("id") UUID orderId,
                           @RequestParam(required = false) Set<String> expand) {
    Order order = orderRepository.findOne(orderId);
    if (order == null) {
      throw new OrderNotFoundException(orderId);
    } else {
      permissionService.canViewOrder(order);
      OrderDto orderDto = orderDtoBuilder.build(order);
      expandDto(orderDto, expand);
      return orderDto;
    }
  }

.. code-block:: Java

  protected void expandDto(Object dto, Set<String> expands) {
    objReferenceExpander.expandDto(dto, expands);
  }

`Here`_ you can find implementation of the method in ObjReferenceExpander class.

Use Database Paging
--------------------

Database paging is vastly more performant and efficient than Java paging or not paging at all.
How much more?  Before the Orderable's search resource was paged in the database, it was paged in
Java.  In Java pulling a page of only 10 Orderables out of a set of 10k Orderables took around 20
seconds. After switching to database paging, this same operation took only 2 seconds (10x more 
performant) and of that 95% of those 2 seconds are spent in an unrelated permission check.

The `database paging pattern`_ was established and as of this writing is not well enough adopted.
Remember when paging to:

#. Follow the `pagination API conventions`_.
#. Use `Spring Data Pageable`_ all the way to the query.
#. `Spring Data projection`_ makes this easy (more so in 1.11+). So code like this just works:
    
    .. code-block:: Java
    
      @Query("SELECT o FROM Orderable o WHERE o.id in ?1")
      Page<Orderable> findAllById(Iterable<UUID> ids, Pageable pageable);

#. If it's an :code:`EntityManager.createQuery()`, you'll need to run 2 queries:  one for a 
   :code:`count()` and one for the (sub) list.
#. If you're a client, *use* the query parameters to page the results - otherwise our convention
   will be to return the largest page we can to you, which is slower.

Follow the pattern in `Orderable search`_.


Eager Fetching & Lazy Loading
------------------------------

Eager fetching and lazy loading refer to the loading strategy an ORM takes when loading related 
Entities to the one that you're interested in.  When done right, eager fetching can eliminate the
N+1 problem in the next section.  When done wrong, your service can consume all it's available
memory and stall out.

Most often eager loading is not the right strategy to choose, and while Hibernate's default is to
always use lazy loading, we should remember that Hibernate uses the JPA recommendation to lazily
load all \*ToMany relationships and eagerly fetch \*ToOne relationships.

Eagerly fetching \*ToOne relationships is not wrong, however we can't talk about eager fetching and 
lazy loading without analyzing what the typical uses of retrieving data/entities is.  For that
we'll look at the N+1 problem.


N+1 loading
^^^^^^^^^^^^

In the simplest terms, N+1 loading occurs when an entity is loaded, related entities are marked as
lazily loaded, and then the Java code (service, controller, etc) navigates to the related entity
causing the JPA implementation to go load that related entity, which typically is an IO event back
to the database.  This is especially egregious when the related entity is actually some sort of 
collection (\*ToMany relationship).  For each element that's navigated to in the relationship, often
another IO call occurs back to the database.

Avoiding N+1 loading is best done through designing for the common case.  Take for example a User
entity, which has a lazily loaded OneToMany relationship with RoleAssignments.  We might think that 
the common case we should design for is updating a user and their RoleAssignments. If we design for 
this we'll likely place the full RollAssignment resource in the representation for GET and PUT of a 
User.  Since the relation is lazily loaded we'll incur N+1 loads:  1 for the User and N for the # 
of RoleAssignments.  If we changed the relation to be eagerly fetched, then we'd pull all N 
RollAssignments when any bit of Java code loaded the User - even if we just needed the User's ID or 
name.

The simplest solution therefore is to use a lazily loaded relation, and remove the full 
representations of RoleAssignments from the User resource.  After all, updating a User is actually 
pretty uncommon compared to retrieving a User, or even retriving the User with RoleAssignments to
check that user's rights.  If we do actually need a User's RoleAssignments, we don't actually want 
to retrieve them with the User, rather we'll likely want a specific sub Resource of a User for 
managing their RoleAssignments.  This sub-resource would typically look like:

- :code:`/api/users/{id}`
- :code:`/api/users/{id}/roleAssignments`

This would optimize the common case (just load a User to get their name/profile), and provide a
seperate resource which could be optimized for pulling that User's RoleAssigments in one trip to the
database.

Summary
^^^^^^^

- Build RESTful resource representations that are shallow:  that is don't load more than just the
  single entity being asked for.
- `No FETCH JOINS`_
- Don't use eager fetching unless it's really safe to do so. It might seem to solve the above 
  problem, but it can go awry quickly.  Just use lazy loading.
- During development you can set `environment variables to show what SQL`_ is actually being run by
  Hibernate.
- Use expand pattern.
- Replace full DTO with the basic version when it exists and it is possible.

Database JOINs are expensive
-----------------------------

Simply put a database join is expensive.  While our `Services should not denormalize`_ to avoid
many joins, we should consider the advice in the FlattenComplexStructures_ section, especially
when such a representation is used frequently by other clients.


Indexes
--------

When done right an index can prevent the database from ever having to go to disk - a slow operation.
Done wrong and a plethora of indexes can eat up memory and not prevent disk operations.

Some tips (PostgreSQL):

- The primary key is indexed.  When you know what you want, using it's primary key, a UUID, is 
  usually the most effecient.
- Foreign keys are not automatically indexed in PostgreSQL, however they almost always should be.
- You almost always want a B-tree index (the default).
- Unique columns are some of the best indicies, when it's not a unique column, keep in mind that
  `low cardinality indexes negatively impact performance`_
- Don't over-index, each index takes up memory.  Choose them based on the common search (i.e. WHERE 
  clause) and prefer to search based on high-cardinality columns with indexes.
- `More indexing tips`_


.. _FlattenComplexStructures:

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

E-tag and if-none-match
------------------------

`HTTP Caching`_ in a nut-shell is supporting the use of fields in an HTTP header that can help
identify if a previous result is no longer valid.  This can be very useful for the typical OpenLMIS
user that is often in an environment with low network bandwidth.

In our Spring services this can be as simple as:

.. code-block:: Java

  @RequestMapping(value = "/someResource", method = RequestMapping.GET)
  public ResponseEntity<SomeEntity> getSomeResource(@PathVariable("id") UUID resourceId) {
    ...
    // do work
    ...

    return ResponseEntity
      .ok()
      .eTag(Integer.toString(someResource.hashCode()))
      .body(someResource);
  }

The key points here are:

- someResource must accurately implement hashCode().
- The Object's hashCode is returned to the HTTP client (browser) in the :code`etag` header.
- On subsequent calls the HTTP client should include the HTTP header `if-none-match` with the
  previously returned `etag` value.  If the etag value is the same, a HTTP 304 is returned, without
  a body, saving network bandwidth.

This simple implementation won't however save the server from processing the request and generating
the :code:`etag` from the Object's hashCode().  If this server operation is particularly expensive,
further optimization should be done in the controller to use a field other than the 
:code:`hashCode()` and to return early:

.. code-block:: Java

  @RequestMapping(value = "/someResource", method = RequestMapping.GET)
  public ResponseEntity<SomeEntity> getSomeResource(
    @RequestHeader(value="if-none-match") String ifNoneMatch,
    @PathVariable("id") UUID resourceId) {
    
    if (false == StringUtils.isBlank(ifNoneMatch)) {
      long versionEtag = NumberUtils.toLong(ifNoneMatch, -1);
      if (someResourceRepo.existsByIdAndVersion(resourceId, versionEtag)) {
        return ResourceEntity
          .ok()
          .etag(ifNoneMatch);
      }
    }

    ...
    // do work
    ...

    return ResponseEntity
      .ok()
      .eTag(Integer.toString(someResource.getVersion())
      .body(someResource);
  }

The key to the above is using a property of an entity that changes every time the object changes,
such as one marked with :code:`@Version`, to use as the resource's etag.  By storing the basis of 
the etag in the database, we can run a query which simply goes and sees if that entity still has 
that version, and if it does we can return a HTTP 304.  The property used here could be anything, 
so long as we can search for it in a way that saves processing time (hint:  a good choice with 
high-cardinality would be a multi-column index on the id and the version).  
Another good choice could be a LastModifiedDate_.

Cache-control
--------------
WIP:

- no-cache
- private
- max-age

.. _SLF4J Profiler: https://www.slf4j.org/extensions.html#profiler
.. _VisualVM: https://visualvm.github.io/
.. _Nginx access log: https://github.com/OpenLMIS/openlmis-nginx#nginx-access-log-format
.. _pagination API conventions: https://github.com/OpenLMIS/openlmis-template-service/blob/master/STYLE-GUIDE.md#pagination
.. _Spring Data Pageable: https://docs.spring.io/spring-data/data-commons/docs/1.6.1.RELEASE/reference/html/repositories.html#repositories.special-parameters
.. _database paging pattern: https://groups.google.com/d/msg/openlmis-dev/WniSS9ZIdY4/B7vNXcchBgAJ
.. _Spring Data projection: https://docs.spring.io/spring-data/rest/docs/current/reference/html/#projections-excerpts.projections 
.. _environment variables to show what SQL: https://stackoverflow.com/questions/30118683/how-to-log-sql-statements-in-spring-boot
.. _Orderable search: https://github.com/OpenLMIS/openlmis-referencedata/blob/8de4c200aaf7ccb3dc1e450eb606185a953a8448/src/main/java/org/openlmis/referencedata/web/OrderableController.java#L157
.. _Services should not denormalize: https://stackoverflow.com/questions/173726/when-and-why-are-database-joins-expensive
.. _No FETCH JOINS: http://learningviacode.blogspot.nl/2012/08/fetch-join-and-cartesian-product-problem.html
.. _low cardinality indexes negatively impact performance: https://www.ibm.com/developerworks/data/library/techarticle/dm-1309cardinal/
.. _More indexing tips: https://devcenter.heroku.com/articles/postgresql-indexes
.. _Http Caching: https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/http-caching
.. _LastModifiedDate: https://docs.spring.io/spring-data/jpa/docs/current/reference/html/#auditing.basics
.. _Here: https://github.com/OpenLMIS/openlmis-fulfillment/blob/0efdc844a4b5870e3368dc97b4dccac13ff5d132/src/main/java/org/openlmis/fulfillment/service/ObjReferenceExpander.java#L91

