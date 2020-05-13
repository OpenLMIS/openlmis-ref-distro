===============
Service Health
===============

In OpenLMIS' Service Architecture it's important that a Service be able to tell our Service 
Registry (`Consul`_) when it's ready to accept new work and when it's not.  If the service doesn't 
inform our Service Registry accurately, then new requests for work might be routed to that service 
from the reverse proxy (`Nginx`_) which won't be fulfilled.

Spring Boot Actuator
====================

In our Spring Boot based services there is a very handy project named `Spring Boot Actuator`_ that 
once enabled turns on a number of useful production features.  One of these is the 
:code:`/actuator/health` endpoint.

To make use of this in OpenLMIS v3 architecture we will:

#. Add Spring Boot Actuator to our Service.
#. Enable the :code:`/actuator/health` endpoint.
#. Register this endpoint with Consul as a health check.

Adding Spring Boot Actuator to our Service 
-------------------------------------------

As simple as adding it as a dependency:

**build.gradle**:

.. code-block:: none

  dependencies {
    ...
    compile "org.springframework.boot:spring-boot-starter-actuator"
    ...
  }

Enabling the :code:`/actuator/health` endpoint 
-------------------------------------

May be done through our default configuration:

**application.properties**:

.. code-block:: none

  management.endpoints.enabled-by-default=false
  management.endpoint.health.enabled=true

Note that we first disable all of the endpoints that Spring Boot Actuator adds to be conservative,
we don't need them (yet).  Next we ensure that the :code:`/actuator/health` endpoint is enabled.

Registering :code:`/actuator/health` with Consul (Service Registry)
-----------------------------------------------------------

First we must allow non-authenticated access to this resource:

**ResourceServerSercurityConfiguration.java**:

.. code-block:: Java

	.antMatchers(
            "/referencedata",
            "/actuator/health",
            "/referencedata/docs/**"
	).permitAll()

Next we need to tell Consul that this endpoint should be used for a health check:

**config.json**:

.. code-block:: json

  "service": {
    "Name": "referencedata",
    "Port": 8080,
    "Tags": ["openlmis-service"],
    "check": {
      "interval": "10s",
      "http": "http://HOST:PORT/actuator/health"
    }
  },

This `Consul check directive`_ will be registered with Consul, letting Consul know that every 10 
seconds it should try this :code:`/actuator/health` endpoint and use the HTTP status to determine the
Service's availability.

And finally we'll need to ensure that the registration script replaces :code:`HOST` and 
:code:`PORT` with the correct values when it sends this to Consul:

**consul/registration.js**:

.. code-block:: javascript

  function registerService() {
    service.ID = generateServiceId(service.Name);

    if (service.check) {
      var checkHttp = service.check.http;
      checkHttp = checkHttp.replace("HOST", service.Address);
      checkHttp = checkHttp.replace("PORT", service.Port);
      service.check.http = checkHttp;
    }

    ...
  }

This `commit has the change`_.

At this point you might be wondering why we left this endpoint unsecured and not mapped to some 
name which is service specific. After all, every running service will use :code:`/actuator/health`. 
What we did not do however is make this endpoint routable by adding it to our RAML or registering 
it as a path for Consul.  This means that our reverse proxy will never try to take a HTTP request 
to :code:`/actuator/health` and route it to any particular service.  Only Consul will know of this 
endpoint and try to access it through the network at the host and port which the Service registered 
itself with.  No client to our reverse proxy will be able to directly access a Service's health 
endpoint.

Health and HTTP Status
-----------------------

The `Consul check directive`_ is looking for the following HTTP statuses:

- 2xx: Everything is okay, send more requests
- 429: Warning, too many requests.  There is a problem, but still send more requests.
- Anything else: failed, not available for servicing requests

The :code:`/actuator/health` endpoint naturally fulfills HTTP :code:`200` when the Service is ready 
and also has the basics of how to report when a service is down (e.g. if the database connection is 
down the endpoint will return a 5xx level error).  This endpoint can do more however. 
`Spring Boot Actuator Health Information`_ has more details about how custom code can be written 
that modifies the health status returned.  This could be especially useful if a Service has a 
dependancy on another system (e.g. integration with ODK or DHIS2), another Service (e.g. Requisition 
needs Reference Data) or another piece of infrastructure (e.g. sending emails, SMS, etc).

.. _Consul: https://www.consul.io/
.. _Nginx: https://nginx.org/
.. _Spring Boot Actuator: https://docs.spring.io/spring-boot/docs/current/reference/html/production-ready-endpoints.html
.. _Consul check directive: https://www.consul.io/docs/agent/checks.html
.. _commit has the change: https://github.com/OpenLMIS/openlmis-referencedata/commit/3bcd75f24dbe60702083771d2c947c713725e15e#diff-426e2baf3a14662065832f6c45702da6
.. _Spring Boot Actuator Health Information: https://docs.spring.io/spring-boot/docs/current/reference/html/production-ready-endpoints.html#production-ready-health
