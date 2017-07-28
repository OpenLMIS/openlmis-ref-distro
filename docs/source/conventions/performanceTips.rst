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

No loading entities unnecessarily
---------------------------------
Don't load an entity object if you don't have to; use Spring Data JPA exists() 
instead. A good example of this is in the RightService for Reference Data. The 
checkAdminRight() checks for a user when it receives a user-based client token.
If the user is checking their own information, they only need to verify the 
existence of the user, instead of getting the full User info (using findOne()).

(mention expanded pattern for this now avail in Spring Boot 1.5)

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
