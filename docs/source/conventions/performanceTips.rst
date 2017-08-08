=================
Performance Tips
=================

Testing and Profiling
======================
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
---------------------------------

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

This will avoid pulling the row, avoid turning a row into a Java object, and in
general can save upwards of 100ms as well as the extra memory overhead.  If the
column is indexed (and well indexed), the database may even avoid a trip to
disk, which typically can bring this check in under a millisecond.

- eager / lazy loading - favor the common case
  (this needs to talk about our biggest mistake to date: overly deep resource
  representations - bad for JPA, bad for network, bad for caching)
- N+1 loading
- database joins are expensive
- primary keys, indexes, and foreign keys
  (prefer primary key, index and what are good/bad ones, foreign keys
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
