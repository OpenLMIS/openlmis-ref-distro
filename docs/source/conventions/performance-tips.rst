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
- don't load if you don't have to, use Spring Data JPA exists()
  (e.g. checkAdminRight's user load)
  (mention expanded pattern for this now avail in Spring Boot 1.5)
- eager / lazy loading - favor the common case
  (this needs to talk about our biggest mistake to date: overly deep resource
  representations - bad for JPA, bad for network, bad for caching)
- N+1 loading
- database joins are expensive
- primary keys, indexes, and foreign keys
  (prefer primary key, index and what are good/bad ones, foreign keys
  aren't indexed)
- permission strings
  (flatten complex structures, incur the higher expense in writes over the more
  common read)

HTTP Cache
==========
- list out etag, if-none-match
- example of where server cycles are still expended - permission strings
- future example of where server cycles are avoided (etag stored/cached or
  audit based)
