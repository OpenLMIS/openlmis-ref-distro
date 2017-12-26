# OpenLMIS BrowserMob-Proxy

Based off of [qautomatron/docker-browsermob-proxy](https://hub.docker.com/r/qautomatron/docker-browsermob-proxy/),
this builds a docker image with a Proxy pre-configured on port 9091 for use in our E2E testing.

See [BrowserMob-Proxy](https://github.com/lightbody/browsermob-proxy) for more configuration.

## Ports

* 9090: HTTP for BrowserMob-Proxy configuration.
* 9091-9121: Ports for Proxy usage.
* 9091: Proxy started with HAR support.

## Example of retrieving HAR

To get interesting results you'll need to route some http/s requests through the proxy at
`localhost:9091`.

```
docker-compose up -d
curl 'http://localhost:9090/proxy/9091/har'
```
