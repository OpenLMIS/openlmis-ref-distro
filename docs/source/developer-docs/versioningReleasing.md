# Versioning and Releasing

## Release Numbering

Version 3 follows the [Semantic Versioning](http://semver.org/) standard:

* **Patch** releases with bug fixes, small changes and security patches will come out on an
  as-needed schedule (3.0.1, 3.0.2, etc). Compatibility with past releases under the Major.Minor
  is expected.
* **Minor** releases with new functionality will come out quarterly and will be
  backwards-compatible (3.1, 3.2, 3.3, etc). Compatibility with past releases under the same
  Major number is expected.
* **Major** releases would be for non-backwards-compatible API changes. None is planned at this
  time (4.0 and above).

Version 2 also followed the above standards.

### Goals

Predictable versioning is critical to enable multiple country implementations to share a common
code base and derive shared value. This is a major goal of the 3.0 Re-Architecture. For example,
Country A's implementation might fix a bug or add a new report, they would contribute that code
to the open source project, and Country B could use it; and Country B could contribute something
that Country A could use. For this to succeed, multiple countries using the OpenLMIS version 3
series must be upgrading to the latest Patch and Minor releases as they become available. Each
country shares their bug fixes or new features with the open source community for inclusion in the
new Patch or Minor release.

### Pre-Releases

Starting with version 3, OpenLMIS supports pre-releases following the Semantic Versioning standard.

Currently we suggest the use of **beta** releases. For example, 3.0 Beta is: 3.0.0-beta.

Note: the use of the hyphen consistent with Semantic Versioning. However a pre-release SHOULD NOT
use multiple hyphens. See the note in **Modifiers** on why.

### Modifiers

Starting with version 3, OpenLMIS utilizes build modifiers to distinguish releases from intermediate
or latest builds. Currently supported:

**Modifier**: SNAPSHOT
**Example**: 3.0.0-beta-SNAPSHOT
**Use**: The SNAPSHOT modifier distinguishes this build as the latest/cutting edge available.  It's
intended to be used when the latest changes are being tested by the development team and should not
be used in production environments.

Note: that there is a departure with Semantic Versioning in that the (+) signs are not used as a
delimiter, rather a hyphen (-) is used. This is due to Docker Hub not supporting the use of plus
signs in the tag name.

For discussion on this topic, see [this
thread](https://groups.google.com/forum/#!topic/openlmis-dev/cDV42HOdvCI). The 3.0.0 semantic
versioning and schedule were also discussed at the [Product Committee meeting on February 14,
2017](https://openlmis.atlassian.net/wiki/display/OP/February+14+2017).

## Rolling a Release

Below is the process used for creating and publishing a release of OpenLMIS 3.x. These steps are
being documented for 3.0 Beta, and this page should be used and updated for 3.0, 3.1, and subsequent
3.x releases.

### Goals

What's the purpose of publishing a release? It gives us a specific version of the software for the
community to test drive and review. Beta releases will be deployed with demo data to the UAT site
[uat.openlmis.org](http://uat.openlmis.org). That will be a public, visible URL that will stay the
same while stakeholders test drive it. It will also have demo data and will not be automatically
wiped and updated each time a new Git commit is made.

### Prerequisites

Before you tag and publish the release, make sure the following are in place:

* Demo data and seed data: make sure you have demo data that is sufficient to demonstrate the
  features of this release. Your demo data might be built into the repositories and used in the
  build process OR be prepared to run a one-time database load script/command.
* Features are completed for this release and are checked in.
* All automated tests pass.
* Release notes and other documentation/publicity is ready for distribution.
* The Release Manager has certifications for remote UAT environment and a docker client installed
  on the machine he or she will be releasing to.

### Steps

When you are ready to create and publish a release (Note that version modifiers should not be used
in these steps - e.g. SNAPSHOT):

1. Select a tag name such as '3.0.0-beta' based on the numbering guidelines above.
1. The service utility library should be released prior to the Services. Publishing to the central
   repository may take some time, so publish at least a few hours before building and publishing the
   released Services:
   1. Update the serviceVersion of GitHub's openlmis-service-util
   1. Check Jenkins built it successfully
   1. At [Nexus Repository Manager](https://oss.sonatype.org/), login and navigate to Staging
      Repositories. In the list scroll until you find **orgopenlmis-NNNN**. This is the staged
      release.
   1. Close the repository, if this succeeds, release it. [More
      information](http://central.sonatype.org/pages/releasing-the-deployment.html).
   1. Wait 1-2 hours for the released artifact to be available on Maven Central. Search here to
      check: [https://search.maven.org/](https://search.maven.org/)
   1. In each OpenLMIS Service's build.gradle, update the dependency version of the library to point
      to the released version of the library (e.g. drop 'SNAPSHOT')
1. In each service, set the **serviceVersion** property in the **gradle.properties** file to the
   version you've chosen. Push this to GitHub, then log on to GitHub and create a release tagged
   with the same tag. Note that GitHub release tags should start with the letter "v", so
   '3.0.0-beta' would be tagged 'v3.0.0-beta'. It's safest to choose a particular commit to use as
   the Target (instead of just using the master branch, default). Also, when you create the version
   in GitHub check the "This is a pre-release" checkbox if indeed that is true. Do this for each
   service/UI module in the project, including the API services and the AngularJS UI repo (note: in
   that repo, the file is called version.properties, not gradle.properties). DON'T update the
   Reference Distribution yet.
   1. Do we need a release branch? No, we do not need a release branch, only a tag. If there are any
      later fixes we need to apply to the 3.0 Beta, we would issue a new beta release (eg, 3.0 Beta
      R1) to publish additional, specific fixes.
   1. Do we need a code freeze? We do not need a "code freeze" process. We will add the tag in Git,
      and everyone can keep committing further work on master as usual. Updates to master will be
      automatically built and deployed at the [Test site](http://test.openlmis.org), but not the [UAT
      site](http://uat.openlmis.org).
   1. **Confirm** that your release tags appear in GitHub and in Docker Hub:
      First, look under the Releases tab of each repository, eg
      https://github.com/OpenLMIS/openlmis-requisition/releases.
      Next, look under Tags in each Docker Hub repository. eg
      https://hub.docker.com/r/openlmis/requisition/tags/ . You'll need to wait for the Jenkins
      jobs to complete and be successful so give this a few minutes.
      Note: After tagging each service, you may also want to change the serviceVersion again so that
      future commits are tagged on Docker Hub with a different tag. For example, after releasing
      '3.1.0' you may want to change the serviceVersion to '3.1.1-SNAPSHOT'. You need to coordinate
      with developers on your component to make sure everyone is working on 'master' branch towards
      that same next release.
      Finally, on Jenkins, identify which build was the one that built and published to Docker/Maven
      the release. Press the Keep the build forever button.
1. In **openlmis-config**, tag the most recent commit with the tag version (including the 'v').
1. Update **docker-compose.yml** in **openlmis-ref-distro** with the release chosen
   1. For each of the services deployed as the new version on DockerHub, update the version in the
      **docker-compose.yml** file to the version you're releasing. See the lines under "services:" →
      serviceName → "image: openlmis/requisition-refui:3.0.0-beta-SNAPSHOT" and change that last part
      to the new version tag for each service.
   1. Commit this change and tag the openlmis-ref-distro repo with the release being made.
1. In order to publish the openlmis-ref-distro documentation to ReadTheDocs:
   1. Edit **collect-docs.py** to change links to pull in specific version tags of README files. In that
      script, change a line like
      `urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-referencedata/master/README.md", "developer-docs/referencedata.md")`
      to
      `urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-referencedata/v3.0.0/README.md, "developer-docs/referencedata.md")`
   1. To make your new version visible in the "version" dropdown on ReadTheDocs, it has to be set as
      "active" in the admin settings on readthedocs (admin -> versions -> choose active versions). Once
      set active the link is displayed on the documentation page (it is also possible to set default
      version).
1. Update **docker-compose.yml** in **openlmis-deployment** for the UAT deployment script with the release
   chosen which is at https://github.com/OpenLMIS/openlmis-deployment/blob/master/deployment/uat_env/docker-compose.yml
   1. For each of the services deployed as a the new version on DockerHub, update the version in the
      **docker-compose.yml** file to the version you're releasing.
   1. Commit this change. (You do not need to tag this repo because it is only used by Jenkins, not
      external users.)
1. Kick off each **-deploy-to-uat** job on Jenkins
   1. **Wait** about 1 minute between starting each job
   1. **Confirm** UAT has the deployed service. e.g. for the auth service:
      http://uat.openlmis.org/auth check that the **version** is the one chosen.
1. Navigate to uat.openlmis.org and ensure it works

Once all these steps are completed and verified, the release process is complete. At this point you
can conduct communication tasks such as sharing the URL and Release Announcement to stakeholders.
Congratulations!


### Updating a Component ServiceVersion

Each component is always working towards some future release, version X.Y.Z-SNAPSHOT. A component
may change what version it is working towards, and when you update the serviceVersion of that
component, the other items below need to change.

These steps apply when you change a component's serviceVersion (changing which -SNAPSHOT the
codebase is working towards):

- Within the component, set the **serviceVersion** property in the **gradle.properties** file to
  the new -SNAPSHOT you've chosen.
  - See Step 3 above for details.
- Update **openlmis-ref-distro** to set **docker-compose.yml** to use the new -SNAPSHOT this
  component is working towards.
  - See Step 5 above for details.
  - Use a commit message that explains your change. EG, "Upgrade to 3.1.0-SNAPSHOT of
    openlmis-requisition component."
- Update **openlmis-deployment** to set each **docker-compose.yml** file in the deployment/ folder
  for the relevant environments, probably uat_env/, test_env/, but not demo_env/
  - See Step 7 above for details.
  - Similar to above, please include a helpful commit message. (You do not need to tag this repo
    because it is only used by Jenkins, not external users.)
- Update **openlmis-contract-tests** to set each **docker-compose...yml** file that includes your
  component to use the new -SNAPSHOT version.
  - Similar to the steps above, see the lines under "services:" and change its version to the new
    snapshot.
  - You do not need to tag this repo. It will be used by Jenkins for subsequent contract test runs.
- (If your component, such as the openlmis-service-util library, publishes to Maven, then other
  steps will be needed here.)
