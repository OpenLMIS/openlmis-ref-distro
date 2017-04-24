# Versioning and Releasing

## Micro-Services are Versioned Independently

OpenLMIS version 3 introduced a micro-services architecture where each component is versioned and
released independently. In addition, all the components are packaged together into a Reference
Distribution. When we refer to OpenLMIS 3.X.Y, we are talking about a release of the Reference
Distribution, called the [ref-distro in GitHub](https://github.com/OpenLMIS/openlmis-ref-distro).
The components inside ref-distro 3.X.Y have their own separate version numbers which are listed on
the Release Notes.

The components are each [semantically versioned](http://semver.org/), while the ref-distro has
"milestone" releases that are conducted roughly quarterly (every 3 months we release 3.2, 3.3, etc).
Each ref-distro release includes specific versions of the other components, both service components
and UI components.

### Where We Publish Releases

All OpenLMIS source code is available on GitHub, and the components have separate repositories.
Releases are tagged on GitHub for all components including the ref-distro. Releases of some
components, such as the service components and UI components, are also published to Docker Hub as
versioned docker images. In addition, we publish releases to Maven for the service components
written in Java Spring along with their service utility library.

## Release Numbering

Version 3 components follow the [Semantic Versioning](http://semver.org/) standard:

* **Patch** releases with bug fixes, small changes and security patches will come out on an
  as-needed schedule (1.0.1, 1.0.2, etc). Compatibility with past releases under the Major.Minor
  is expected.
* **Minor** releases with new functionality will be backwards-compatible (1.1, 1.2, 1.3, etc).
  Compatibility with past releases under the same Major number is expected.
* **Major** releases would be for non-backwards-compatible API changes. When a new major version
  of a component is included in a Reference Distribution release, the Release Notes will document
  any migration or upgrade issues.

The Version 3 Reference Distribution follows a milestone release schedule with quarterly releases.
Release Notes for each ref-distro release will include the version numbers of each component
included in the distribution. If specific components have moved by a Minor or Major version number,
the Release Notes will describe the changes (such as new features or any non-backwards-compatible
API changes or migration issues).

Version 2 also followed the semantic versioning standard.

### Goals

Predictable versioning is critical to enable multiple country implementations to share a common
code base and derive shared value. This is a major goal of the 3.0 Re-Architecture. For example,
Country A's implementation might fix a bug or add a new report, they would contribute that code
to the open source project, and Country B could use it; and Country B could contribute something
that Country A could use. For this to succeed, multiple countries using the OpenLMIS version 3
series must be upgrading to the latest Patch and Minor releases as they become available. Each
country shares their bug fixes or new features with the open source community for inclusion in the
next release.

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

### We Prefer Coordination over Branching

Because each component is independently, semantically versioned, the developers working on that
component need to coordinate so they are working towards the same version (their next release).

Each component's repository has a version file (gradle.properties or version.properties) that
states which version is currently being developed. By default, we expect components will be working
on the master branch towards a Patch release. The developers can coordinate any time they are ready
to work on features (for a Minor release).

If developers propose to break with past API compatibility and make a Major release of the
component, that should be discussed on the [Dev
Forum](https://groups.google.com/forum/#!forum/openlmis-dev). They should be ready to articulate a
clear need, to evaluate other options to avoid breaking backwards-compatibility, and to document a
migration path for all existing users of the software. Even if the Dev Forum and component lead
decide to release a Major version, we still require automated schema migrations (using Flyway) so
existing users will have their data preserved when they upgrade.

Branching in git is discouraged. OpenLMIS does not use git-flow or a branching-based workflow. In
our typical workflow, developers are all contributing on the master branch to the next release of
their component. If developers need to work on more than one release at the same time, then they
could use a branch. For example, if the component is working towards its next Patch, such as
1.0.1-SNAPSHOT, but a developer is ready to work on a big new feature for a future Minor release,
that developer may choose to work on a branch. Overall, branching is possible, but we prefer to
coordinate to work together towards the same version at the same time, and we don't have a
branch-driven workflow as part of our collaboration or release process.

### Code Reviews and Pull Requests

We expect all code committed to OpenLMIS receives either a review from a second person or goes
through a pull request workflow on GitHub. Generally, the developers who are dedicated to working
on OpenLMIS itself have commit access in GitHub. They coordinate in Slack, they plan work using
JIRA tickets and sprints, and during their ticket workflow a code review is conducted. Code should
include automated tests, and the ticket workflow also includes a human Quality Assurance (QA) step.

Any other developers are invited to contribute to OpenLMIS using Pull Requests in GitHub at any
time. This includes developers who are implementing, extending and customizing OpenLMIS for
different local needs.

For more about the coding standards and how to contribute, see **contributionGuide.md**.

### Future Strategies

As the OpenLMIS version 3 installation base grows, we expect that additional strategies will be
needed so that new functionality added to the platform will not be a risk or a barrier for existing
users. Feature Toggles is one strategy the technical community is considering.

## Rolling a Release

Below is the process used for creating and publishing a release of each component as well as the
Reference Distribution (OpenLMIS 3.X.Y).

### Goals

What's the purpose of publishing a release? It gives us a specific version of the software for the
community to test drive and review. Beta releases will be deployed with demo data to the UAT site
[uat.openlmis.org](http://uat.openlmis.org). That will be a public, visible URL that will stay the
same while stakeholders test drive it. It will also have demo data and will not be automatically
wiped and updated each time a new Git commit is made.

### Prerequisites

Before you release, make sure the following are in place:

* Demo data and seed data: make sure you have demo data that is sufficient to demonstrate the
  features of this release. Your demo data might be built into the repositories and used in the
  build process OR be prepared to run a one-time database load script/command.
* Features are completed for this release and are checked in.
* All automated tests pass.
* Documentation is ready. For components, this is the CHANGELOG.md file, and for the ref-distro
  this is a Release Notes page in the wiki.

### Releasing a Component (or Updating the Version SNAPSHOT)

Each component is always working towards some future release, version X.Y.Z-SNAPSHOT. A component
may change what version it is working towards, and when you update the serviceVersion of that
component, the other items below need to change.

These steps apply when you change a component's serviceVersion (changing which -SNAPSHOT the
codebase is working towards):

- Within the component, set the **serviceVersion** property in the **gradle.properties** file to
  the new -SNAPSHOT you've chosen.
  - See Step 3 below for details.
- Update **openlmis-ref-distro** to set **docker-compose.yml** to use the new -SNAPSHOT this
  component is working towards.
  - See Step 5 below for details.
  - Use a commit message that explains your change. EG, "Upgrade to 3.1.0-SNAPSHOT of
    openlmis-requisition component."
- Update **openlmis-deployment** to set each **docker-compose.yml** file in the deployment/ folder
  for the relevant environments, probably uat_env/, test_env/, but not demo_env/
  - See Step 7 below for details.
  - Similar to above, please include a helpful commit message. (You do not need to tag this repo
    because it is only used by Jenkins, not external users.)
- Update **openlmis-contract-tests** to set each **docker-compose...yml** file that includes your
  component to use the new -SNAPSHOT version.
  - Similar to the previous steps, see the lines under "services:" and change its version to the new
    snapshot.
  - You do not need to tag this repo. It will be used by Jenkins for subsequent contract test runs.
- (If your component, such as the openlmis-service-util library, publishes to Maven, then other
  steps will be needed here.)

### Releasing the Reference Distribution (openlmis-ref-distro)

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
      Note: There is consideration underway about using a git branch to coordinate the ref-distro
      release.
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


