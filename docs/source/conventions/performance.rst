####################
Performance Testing
####################

OpenLMIS focuses on performance metrics that are typical in web-applications:

- Calls to the server - how many milliseconds does this single operation take,
  and is the memory usage reasonable.
- Network load - how large are the resources returned from the server.
  Typically OpenLMIS is designed to work in network-constrained locations, so
  the size, in bytes, of each resource is important.
- The number of calls the Reference UI makes - again networks being what they,
  we want to minimize the number of connections that are made to accomplish
  a user workflow as each connection adds overhead.
- Size of the "working" data set.  Here working data is defined as the data
  that's needed for a user to accomplish a task.  Examples are typically
  Reference Data:  # of Products, # of Facilities, # of Users, etc.  Though also
  the # of Requisitions or # of Stock Cards might factor into a user's working
  data.  Since OpenLMIS typically manages countries, it's important that we're
  efficient in managing country-level data sets.

There are some areas of Performance however that OpenLMIS typically doesn't
focus as much on:

- Scaling - typically we're not concerned with tens of thousands of people
  needing to use the system concurrently.  Likewise we don't typically worry
  yet about surges or dips in user activity requiring more or less resources to
  serve those users.

Getting Started
----------------

OpenLMIS uses Apache JMeter_ to test RESTful endpoints.  We use Taurus_, and
it's YAML format, to write our test scenarios and generate reports which our CI
server can present as an artifact of every successful deployment to our CD
test server.

Keeping to our conventions, Taurus_ is used through a Docker image, with a
simple script located at `./performance/test.sh` with tests in the directory
`./performance/tests/` of a Service.  Any `*.yml` file in that test directory
will be fed to Taurus to be used against `https://test.openlmis.org`.

Running `test.sh` will place JMeter output as well as Taurus output under
`./build/performance-artifacts/`.  The file `stats.xml` has the final summary
performance metrics.  Files of note when developing test scenarios:

* `error-N.jtl` - Contains errors and requests that led to those errors from the
  HTTP server.
* `JMeter-N.err` - Contains JMeter errors where JMeter didn't understand the
  test scenario.
* `modified_requests-N.jmx` - Contains the generated JMeter requests
  (after Taurus generation).
* `kpi-N.jtl` - Individual metrics of a test scenario.


Running in CI
--------------

Tests run in a Jenkin's Job that ends in `-performance`.  This job is run as
part of each Service's build pipeline *that results in a deployment to the test
server*.

The reports are presented using `Performance Plugin`_.  When looking at this
report you'll see:

* A graph that shows all of the endpoints (requests) over time.
* A report for a build which includes an average over time, as well as a table
  showing KPIs of each request.

A simple Scenario (with authentication)
----------------------------------------

Nearly all of our RESTful resources require authentication, in this example
we'll show a basic test scenario that includes authentication.  The syntax and
features used here are documented at Taurus' page on the `JMeter executer`_.

.. code-block:: yaml

  execution:
    - concurrency: 1
      hold-for: 1m
      scenario: users-get-one
  scenarios:
    get-user-token:
      requests:
        - url: ${__P(base-uri)}/api/oauth/token
          method: POST
          label: GetUserToken
          headers:
            Authorization: Basic ${__base64Encode(${__P(basic-auth)})}
          body:
            grant_type: password
            username: ${__P(username)}
            password: ${__P(password)}
          extract-jsonpath:
            access_token:
              jsonpath: $.access_token
    users-get-one:
      requests:
        - include-scenario: get-user-token
        - url: ${__P(base-uri)}/api/users/a337ec45-31a0-4f2b-9b2e-a105c4b669bb
          method: GET
          label: GetAdministratorUser
          headers:
            Authorization: Bearer ${access_token}

The `execution` block defines for our test scenario `users-get-one` that runs
1 concurrent user, for one minute.  Notice that this definition is for
the simplest of test executions - 1 user, run it enough times to get a useful
sampling.  We use this sort of test execution to first get a sense of what our
endpoint's single-user characteristics are.

Next notice that we have two scenarios defined:

#. get-user-token - this is a reusable scenario, which gets a basic user
   authentication token, and through the `extract-jsonpath` saves it to a
   variable named `access_token`.
#. users-get-one - this is the test scenario we're primarily interested in:
   exercise the `/api/users/{a specific users uuid}`.  We pass the previously
   obtained `access_token` through the HTTP request's headers.

Summary
^^^^^^^^

* First test the most basic of environments:  1 user, enough times to get useful
  sample size.
* Re-use the scenario to obtain an access_token using `include-scenario`.
* It's generally OK to use demo-data identifiers (the user's UUID) - though it
  couples the test to the demo-data, it will provide consistent results.
* Give each request a clear, semantic `label`.  This will be used later in
  pass-fail criteria.

Testing collections
--------------------

To the simple Scenario we're going to now test the performance of returning
a collection of a resource:

.. code-block:: yaml

  users-search-one-page:
    requests:
      - include-scenario: get-user-token
      - url: ${__P(base-uri)}/api/users/search?page=1&size=10
        method: POST
        label: GetAUserPageOfTen
        body: '{}'
        headers:
          Authorization: Bearer ${access_token}
          Content-Type: application/json

Here we're testing the Users resource by asking for 1 page of 10 users.

Summary
^^^^^^^

* When testing the performance of collections, the result will be influenced
  by the number of results returned.  Due to this prefer to test a paginated
  resource, and always ask for a number that exists (i.e. don't ask for 50 when
  demo-data only has 40).
* Searching often requires a POST, in this case the query parameters must be in
  the URL.

Testing complex workflows
-------------------------

A complex workflow might be:

#. GET a list of periods for which requisitions may be initiated.
#. Create a new Requisition resource by POSTing with the previously returned
   periods available.
#. DELETE the previously created Requisition resource, so that we may test
   again.

.. code-block:: yaml

  initiate-requisition:
    requests:
      - url: ${__P(base-uri)}/api/oauth/token
        method: POST
        label: GetUserToken
        headers:
          Authorization: Basic ${__base64Encode(${__P(user-auth)})}
        body:
          grant_type: password
          username: ${__P(username)}
          password: ${__P(password)}
        extract-jsonpath:
          access_token:
            jsonpath: $.access_token
      # program = family planning, facility = comfort health clinic
      - url: ${__P(base-uri)}/api/requisitions/periodsForInitiate?programId=10845cb9-d365-4aaa-badd-b4fa39c6a26a&facilityId=e6799d64-d10d-4011-b8c2-0e4d4a3f65ce&emergency=false
        method: GET
        label: GetPeriodsForInitiate
        headers:
          Authorization: Bearer ${access_token}
        extract-jsonpath:
          periodUuid:
            jsonpath: $.[:1]id
        jsr223:
          script-text: |
            String uuid = vars.get("periodUuid");
            uuid = uuid.replaceAll(/"|\[|\]/, "");
            vars.put("periodUuid", uuid);
      - url: ${__P(base-uri)}/api/requisitions/initiate?program=10845cb9-d365-4aaa-badd-b4fa39c6a26a&facility=e6799d64-d10d-4011-b8c2-0e4d4a3f65ce&suggestedPeriod=${periodUuid}&emergency=false
        method: POST
        label: InitiateNewRequisition
        headers:
          Authorization: Bearer ${access_token}
          Content-Type: application/json
        extract-jsonpath:
          reqUuid:
            jsonpath: $.id
        jsr223:
          script-text: |
            String uuid = vars.get("reqUuid");
            uuid = uuid.replaceAll(/"|\[|\]/, ""); # remove quotes and []
            vars.put("reqUuid", uuid);
      - url: ${__P(base-uri)}/api/requisitions/${reqUuid}
        method: DELETE
        label: DeleteRequisition
        headers:
          Authorization: Bearer ${access_token}

Summary
^^^^^^^

* When creating a new RESTful resource (e.g. PUT or POST), we may need to
  clean-up after ourselves in order to run more than one test.
* JSR223 blocks allow us to execute basic Groovy (default).  This can be
  especially useful when you need to clean-up a JSON result from a previous
  response, such as a UUID, to use in the next request.

Simple stress testing
---------------------

As mentioned, OpenLMIS performance tests tend to focus first on basic
execution environments where we're only testing 1 user interaction at a time.
However there is a need to do basic stress testing, especially for endpoints
which are used frequently.  For example we've seen the authentication resource
used repeatedly in all our previous examples.  Lets stress test it.

.. code-block:: yaml

  modules:
    local:
      sequential: true

  execution:
    - concurrency: 10
      hold-for: 2m
      scenario: get-user-token
    - concurrency: 50
      hold-for: 2m
      scenario: get-service-token

  scenarios:
    get-user-token:
      requests:
        - url: ${__P(base-uri)}/api/oauth/token
          method: POST
          label: GetUserToken
          headers:
            Authorization: Basic ${__base64Encode(${__P(user-auth)})}
          body:
            grant_type: password
            username: ${__P(username)}
            password: ${__P(password)}
    get-service-token:
      requests:
        - url: ${__P(base-uri)}/api/oauth/token
          method: POST
          label: GetServiceToken
          headers:
            Authorization: Basic ${__base64Encode(${__P(service-auth)})}
          body:
            grant_type: client_credentials

Here we've defined 2 tests:

#. Authenticate as if you're a person.
#. Authenticate as if you're another Service (a Service token).

The stress testing here introduces important changes in our `execution` block:

.. code-block:: yaml

    - concurrency: 10
      hold-for: 2m
      scenario: get-user-token

Instead of defining 1 user, here we'll have 10 concurrent ones.  Instead of
running the test for 1 minute, we're going to run the test as many times as we
can for 2 minutes.  For further options see the Taurus' `Execution doc`_.

When stress testing, it's important to remember that too much simply isn't
useful, and only slows down the test.  Nor do we presently have a
test infrastructure in place that allows for tests to originate from multiple
hosts.

Summary
^^^^^^^

- You can define multiple execution definitions for the same scenario, so the
  first might give us the basic performance characteristics, the second might
  be a stress test.
- By default the tests defined in the `execution` block are run in parallel.
  This can be changed to by ran sequential with `sequential: true`.
- Choose a reasonable number of concurrent users.  Typically less than a dozen
  is enough.
- Choose a reasonable time to hold the test for.  Typically 1-2 minutes is
  enough, and no more than 5 minutes unless justifiable.
- Remember that we don't have a performance testing infrastructure in place
  that can concurrently send requests to our application from multiple hosts.
  OpenLMIS performance testing typically only requires the most basic stress
  testing.

Testing file uploads
--------------------

In this short example we're going to send a request to the catalog items endpoint
and upload some items as a CSV file.

.. code-block:: yaml

  upload-catalog-items:
    requests:
      - include-scenario: get-user-token
      - url: ${__P(base-uri)}/api/catalogItems?format=csv
        method: POST
        label: UploadCatalogItems
        headers:
          Authorization: Bearer ${access_token}
        upload-files:
          - param: file
            path: /tmp/artifacts/catalog_items.csv

Summary
^^^^^^^

* When uploading a file we don't have to worry about setting correct content header
  as Taurus take care of it on its own when using upload-files block. This behavior
  is described in the `HTTP Requests`_ of the Taurus user manual

Pass-fail criteria
------------------

With the above tests defined, we can now write pass-fail criteria.  This is
especially useful if we want our test to fail when the performance is less than
what we've defined.

.. code-block:: yaml

  reporting:
      - module: passfail
        criteria:
          - avg-rt of GetUserToken>300ms, continue as failed
          - avg-rt of GetServiceToken>300ms, continue as failed

This allows us to fail the test if the average response time for either of the
two tests was greater than 300ms.  See the `Taurus Passfail doc` for more.

Summary
^^^^^^^

* Write the pass-fail criteria within the test definition.

Performance Acceptance Criteria
================================

With Taurus we can now add basic acceptance criteria when working on new issues.
For example the acceptance criteria might say:

- the endpoint to retrieve 10 users should complete in 500ms for 90% of users

This would lead us to write a performance test for this new GET operation to
retrieve 10 users, and we'd add a pass-fail criteria such as:

.. code-block:: yaml

  reporting:
      - module: passfail
        criteria:
          Get 10 Users is too slow: p90 of Get10Users>500ms, continue as failed

Read the `Taurus Passfail doc`_ for more.

Next Steps (WIP)
================

We've covered basic performance testing, stress testing, and pass-fail criteria.
Next we'll be adding:

* Loading performance-oriented data sets (e.g. what happens to these requests
  when there are 10,000 products).

* Using Selenium to mimic browser interactions, to give us:

  * How many http requests does a page incur.
  * Network payload size.

* Failing deployments based on performance results.


.. _Taurus: http://gettaurus.org/
.. _Execution doc: http://gettaurus.org/docs/ExecutionSettings/#Load-Profile
.. _Taurus Passfail doc: http://gettaurus.org/docs/PassFail/
.. _JMeter: http://jmeter.apache.org/
.. _JMeter executer: http://gettaurus.org/docs/JMeter/
.. _Performance Plugin: https://wiki.jenkins.io/display/JENKINS/Performance+Plugin
.. _HTTP Requests: https://gettaurus.org/docs/JMeter/#HTTP-Requests
