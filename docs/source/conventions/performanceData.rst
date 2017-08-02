#################
Performance Data
#################

Performance data in OpenLMIS is meant to be data that helps us answer questions
such as:

- What happens to the server and the operations it provides when there are
  10,000 orderables, users, facilities, requisitions, etc?
- What happens when all that data is being used by many concurrent users?
- What's the impact on network performance, especially for those in low resource
  environments?
- What sort of deployment topology works best for typical implementations?
- Does the UI (and possibly other clients) display large sets of data well?

Some basic characteristics of performance data:

- there is a lot of it
- it doesn't have to look nice or make that much sense to domain experts (e.g.
  a Vaccine could be randomly generated to be ordered through the essential meds
  Program, and that's okay).  Lorem ipsum and random numbers are just fine here.
- it must be deployable in a deployment topology that is as close to a
  production setup as possible.  After all it's for performance testing, and
  performance testing on a local laptop doesn't tell us (much) about anything a
  production server running in the cloud would experience.


Where is performance data located?
===================================

Performance data is stored in Git within each Service that defines it, much
like demo-data.  In fact in most cases Performance Data builds off of demo-data,
and so a Service should be able to load performance data or demo-data in very
similar ways.

How to load performance data
==============================

Like demo-data, performance data is an optional set of data that may be loaded
when the Service *starts*.  To do this a Service should load performance data,
likely after any demo-data, by looking for the profiles set in the environment
variable :code:`spring.profiles.active`.  If this environment variable contains
the string :code:`performance-data`, then the service should load this data
before it's operational for use.

How to create and manage performance data
===========================================

Performance data is generated with the help of the tool `Mockaroo`_.  This
tool is used to define schemas which match the Service's tables and it may
generate large CSVs which are then stored in the Service in git.  CSVs are used
as they easily enable the use of foreign key / UUID lookups when a Mockaroo
dataset is used (as this `Mockaroo dataset video`_ demonstrates).  These CSVs
are placed in git for the Service to load the data, however if the Service needs
new performance data, the database schema changes or something else causes the
performance data to need to be updated, the OpenLMIS Mockaroo account should
be used to generate a new set, which will then be stored in the Service.

What types of performance data should be created?
==================================================

Performance data is relatively expensive and tedious to maintain given the
questions we're trying to answer.  While it's necessary to do so, here are some
general guidelines for what to spend time generating, and what not to:

Do
---

- Generate performance data that will allows performance tests to reflect
  country data needs.
- Try to generate data that's more right than random.  Random is okay, However
  if the tool has a sufficiently large set of facilities, or products, use it.
- Respect database constraints, foreign keys, references to IDs in other
  Services etc
- Keep in mind that some UUIDs need to be *known*.  They can't be generated.
  You'll need to know a few of these key UUIDs (e.g. Program, User, etc) in
  order to construct useful performance tests.

Don't
------

- Overcomplicate the data.  1 billion facilities, a trillion requisitions, 1000
  programs just aren't anywhere near likely and just take longer to load and
  more time to maintain.  10k facilities, 100k requisitions, 10 programs are
  much more representative.
- Similarly, don't generate data when demo-data already has enough.  E.g. demo
  data already has a few Programs, you're time is better spent setting up one
  of those programs to have 10k facility type approved products than you are
  generating 100 programs.
- Don't build performance tests off of generated IDs.  While Mockaroo makes it
  easy to build sets of data with referential integrity, using generated IDs
  hardcoded in performance tests will result in more brittle tests.

.. _Mockaroo: http://mockaroo.com
.. _Mockaroo dataset video: https://youtu.be/XATDlwG1azU
