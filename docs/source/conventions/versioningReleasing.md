# Versioning and Releasing

## Micro-Services are Versioned Independently

OpenLMIS version 3 introduced a micro-services architecture where each component is versioned and
released independently. In addition, all the components are packaged together into a **Reference
Distribution**. When we refer to OpenLMIS 3.X.Y, we are talking about a release of the Reference
Distribution, called the [ref-distro in GitHub](https://github.com/OpenLMIS/openlmis-ref-distro).
The components inside ref-distro 3.X.Y have their own separate version numbers which are listed on
the Release Notes.

The components are each [semantically versioned](http://semver.org/), while the ref-distro has
"milestone" releases that are conducted roughly quarterly (every 3 months we release 3.2, 3.3, etc).
Each ref-distro release includes specific versions of the other components, both service components
and UI components.

### Where We Publish Releases

All OpenLMIS source code is available on GitHub, and the components have separate repositories.
Releases are tagged on GitHub for all components as well as the ref-distro. Releases of some
components, such as the service components and UI components, are also published to [Docker
Hub](https://hub.docker.com/u/openlmis/) as versioned docker images. In addition, we publish
releases of the [service utility library](https://github.com/OpenLMIS/openlmis-service-util) to
Maven. Moreover, release builds are kept on Jenkins forever by default.

## Release Process

Starting with OpenLMIS 3.2.1, each release of the Reference Distribution will go through a
Release Candidate process. A Release Candidate will be shared for a Review Period of at least one
week to allow for manual regression testing and to allow community review and input. The goal is
that we catch and fix issues in order to put out higher-quality releases.

The following diagram illustrates the process, and each step is explained in detail below.

![Release Candidate Process Diagram](https://raw.githubusercontent.com/OpenLMIS/openlmis-ref-distro/master/docs/source/conventions/ReleaseCandidateProcessDiagram-Oct2017-fromGliffy.png)

### Active Development

* Multiple agile teams develop OpenLMIS services/components and review and incorporate Pull Request contributions
* Microservices architecture provides separation between the numerous components
* Automated test coverage prevents regressions and gives the team the safety net to release often
* Continuous Integration and Deployment (CI/CD) ensures developers get immediate feedback and QA activities can catch issues quickly
* Code is peer reviewed during Jira ticket workflow and in Pull Requests
* Documentation, CHANGELOGs and demo data are kept up-to-date as code development happens in each service/component

### Do Release Preparation & Code Freeze

* Verify the pre-requisites, including all automated tests are passing and all CHANGELOGs are up-to-date; see Release Prerequisites below under Rolling a Release
* Conduct a manual regression test cycle 1-2 weeks before the release, if possible
* Begin a Code Freeze: shift agile teams' workloads to bugs and clean-up, rather than committing large new features or breaking changes ("slow down" 1-2 weeks before release)

  Note: Branching is not part of the current process (see 'We Prefer Coordination over Branching' section below), but may be adopted in the future along with CI/CD changes to support more teams working in parallel.

* Write draft Release Notes including sections on 'Compatibility', 'Changes to Existing Functionality', and 'New Features'
* Schedule or timing for releases is documented above and may be discussed and revised by the community

### Publish a Release Candidate

* Each component that has any changes since the last release is released and semantically versioned (e.g., openlmis-requisition:6.3.4 or openlmis-newthing:1.0.0-beta)

  Note: Usually, all components are released with the Reference Distribution. Sometimes, due to exceptional requests, the team may release a service/component at another time even when there is not another Reference Distribution release.

* Reference Distribution Release Candidate is released with these components (e.g., openlmis-ref-distro:3.7.0-rc1)

  Note: We archive permanent documentation for every release, but not for every release candidate.

* Share Release Candidate with the OpenLMIS community along with the draft Release Notes and invite testing and feedback

See the 'Rolling a Release' section further below for the specific technical steps to build, tag and
publish a release of components and the Reference Distribution.

### Review Period

The overall timeline for review period starts when the first Release Candidate is shared and should last at least 1 week, during which time subsequent Release Candidates may be published.

* The community is alerted of the upcoming release candidate date and review period via Slack and the listservs. 
* Active Development is paused and the only development work that happens is release-critical bug fixes or work on branches (note: branches are not yet recommended and not supported by CI/CD).
* The team conducts a full manual regression test cycle (including having developers conduct testing) according to the Release Candidate Test Plan. For an example, see the [3.2.1 Regression Test Plan](https://openlmis.atlassian.net/wiki/spaces/OP/pages/123961802/3.2.1+Regression+Test+Plan).  The test plan is included in the final Release Notes.
* Community members are requested to conduct user acceptance testing to submit bugs and issues with the release candidate. Members can review and leverage the [OpenLMIS manual test cases](https://openlmis.atlassian.net/projects/OLMIS?selectedItem=com.thed.zephyr.je__project-centric-view-tests-page).
* OpenLMIS will run automated performance testing and review results.
* Manual bug reports are submitted in Jira, see the [Reporting bugs section](http://docs.openlmis.org/en/latest/contribute/contributionGuide.html#reporting-bugs) for details on how to submit bugs to OpenLMIS. All bugs and issues related to the Release Candidate must be associated with the specific Release Candidate Bugs epic. Bugs can be identified in the code, documentation, and translations.
* A triage team will review and triage all bugs submitted on a daily bases during the review period.

### Fix Critical Issues

Are there critical bugs or issues associated with the release candidate? If not, after the first Release Candidate (RC1) OpenLMIS may move
directly to a release. Otherwise, OpenLMIS will fix critical issues and publish a new Release Candidate
(e.g. RC2).

* Developers fix critical issues in code, documentation, and translations. Only commits for critical issues will be accepted. Other commits will be rejected.
* Every commit is reviewed to determine whether portions or all of the full regression test cycle must be repeated
* And we continue to hold every ticket up to our on-going guidelines and expectations:
  * Every commit is peer reviewed and manually tested, and should include automated test coverage to meet guidelines
  * Every commit must correspond to a Jira ticket and have gone through review and QA steps, and have Zephyr test cases in Jira

Once critical issues are fixed, publish a new Release Candidate and conduct another Review Period.

### Publish the Release

When a Release Candidate has gone through a Review Period without any critical issues found, then
this release candidate becomes the Golden Master to be published as an official release of OpenLMIS.

* Update the Release Notes to state that this is the official release and include the date
* Release the Reference Distribution; the exact code and components in the Golden Master Release Candidate are tagged as the OpenLMIS Reference Distribution release with a version number tag (e.g. openlmis-ref-distro:3.7.0)
* Share the Release with the OpenLMIS community along with the final Release Notes

After publishing the release, Active Development can resume.

#### Releasing components outside of a Ref Distro release (draft)

At times OpenLMIS will release
stable components outside the process of releasing a new Ref Distro.  When a component is released
without the Ref Distro it is done on its own - without the benefits of the rigirous release process of the Ref Distro.

Any component may be released at any time.  However to release a component, it must pass the following criteria:

* All automated tests of the component must be passing.
* All dependancies must also be co-released and their automated tests passing if a change in the dependancy is needed to successfully
release the component.
* The release must be stable - no half-finished features or fixes.
* Since the release of the component is outside of the Ref Distro release process, **implementers should be careful** in taking such
releases as they haven't been fully tested in the larger context of the Ref Distro.

### Implementation Release Process

A typical OpenLMIS implementation is composed of multiple core OpenLMIS components plus some custom
components or extensions, translations and integrations. It is recommended that OpenLMIS
implementations follow a similar process as above to receive, review and verify that updates of
OpenLMIS perform correctly with their customizations and configuration.

Key differences for implementation releases:

* **Upstream Components**: Implementations treat the OpenLMIS core product as an "upstream" vendor distribution. When a new core Release Candidate or Release are available, they are encouraged to pull the new upstream OpenLMIS components into the implementations CI/CD pipeline and conduct testing and review.
* **Independent Review**: It is critical for the implementation to conduct its own Review Period. It may be a process similar to the diagram above, with multiple Release Candidates for that implementation and with rounds of manual regression testing to ensure that all the components (core + custom) work together correctly.
* **Conduct Testing/UAT on Staging**: Implementations should apply Release Candidates and Releases onto testing/staging environments before production environments. Testing should be conducted on an environment that is a mirror of production (with a recent copy of production data, same server hardware, same networks, etc). There may be a full manual regression test cycle or a shorter smoke test as part of applying a new version onto the production environment. There should also be a set of automated tests and performance tests, similar to the core release process above, but with production data in place to verify performance with the full data set.
* **Follow Best Practices**: When working with a production environment, follow all best practices: schedule a downtime/maintenance window before making any changes; take a full backup of code, configuration and data at the start of the deployment process; test the new version before re-opening it to production traffic; always have a roll-back plan if issues arise in production that were not caught in previous testing.

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

Each component's repository has a version file (gradle.properties or project.properties) that
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

- If the component that you are about to release depends on the openlmis-service-util, verify
  that it uses a stable version of that library. If it uses a snapshot version, a release of
  openlmis-service-util is required before you can proceed.
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

**Note:** usually during a release many docker images are built in a short time. It may happen that
the CI build process fails because of a docker pull rate limit which is 250 per 6 hours. It is a
limitation of a free version of a dockerhub account.

### Patch Releasing a Component

1. Create a hotfix branch that includes 'rel-' prefix and the patch version, e.g. 'rel-10.0.1'
2. Set the **serviceVersion** property in the **gradle.properties** file to the patch version with
SNAPSHOT suffix, e.g. 10.0.1-SNAPSHOT.
3. Make sure that Jenkins builds the branch successfully. If needed, run the job with
'contractTestsBranch' parameter set to the branch of **contract-tests** repository containing your
ref-distro release, e.g. 'v3.3.0'.
4. Run performance tests
5. If all passes, remove SNAPSHOT suffix from the **serviceVersion** property.
6. Verify that the patch release is available on docker hub.


### Releasing the Reference Distribution (openlmis-ref-distro)

When you are ready to create and publish a release (Note that version modifiers should not be used
in these steps - e.g. SNAPSHOT):

1. Select a tag name (e.g. '3.3.0') based on the numbering guidelines above.
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
1. In each service, branch for release. The branch name should start with 'rel-' followed by version
   of the service, e.g. 'rel-6.0.0'. Set the **serviceVersion** property in the
   **gradle.properties** file to the next version, which should simply be the version without the
   SNAPSHOT suffix (e.g. if the serviceVersion was 6.0.0-SNAPSHOT, it should be 6.0.0). Push this to
   GitHub, then log on to GitHub and create a release tagged with the same tag. Note that GitHub
   release tags should start with the letter "v", so '6.0.0' would be tagged 'v6.0.0'. Choose
   the release branch to use as the Target. Also, when you create the version in GitHub check the
   "This is a pre-release" checkbox if indeed that is true.
   1. Do this for each service/UI module in the project, including the API services and the UI
      repos (note: in those repos, the file is called project.properties, not gradle.properties).
      DON'T update the Reference Distribution yet.
   1. Do we need a code freeze? We do not need a "code freeze" process. We are branching for release,
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
      '6.0.0' you may want to change the serviceVersion to '6.0.1-SNAPSHOT'. You need to coordinate
      with developers on your component to make sure everyone is working on 'master' branch towards
      that same next release.
   1. Finally, on Jenkins, identify which build was the one that built and published to Docker/Maven
      the release. Press the Keep the build forever button.
1. Update **.env** in **openlmis-ref-distro** with the release tag name chosen (e.g '3.3.0')
   1. For each of the services (and the Reference UI) deployed as the new version on DockerHub,
      update the version in the **.env** file to the version you're releasing.
   1. Commit this change and tag the openlmis-ref-distro repo with the release being made.
      Note: There is consideration underway about using a git branch to coordinate the ref-distro
      release, to perform this step and the next one.
1. In order to publish the openlmis-ref-distro documentation to ReadTheDocs:
   1. Edit **collect-docs.py** to change links to pull in specific version tags of README files. In that
      script, change a line like
      `urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-referencedata/master/README.md", "developer-docs/referencedata.md")`
      to
      `urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-referencedata/v3.0.0/README.md, "developer-docs/referencedata.md")`
   1. Edit **index.rst** and the ERD RST files under **docs/source/components** to change links to
      pull in specific build version numbers of static API documentation and ERD zip files. In
      those files, change a URL like
      `http://build.openlmis.org/job/OpenLMIS-auth-pipeline/job/master/lastSuccessfulBuild/artifact/api-definition.html`
      to
      `http://build.openlmis.org/job/OpenLMIS-auth-pipeline/job/master/362/artifact/api-definition.html`
      and
      `http://build.openlmis.org/job/OpenLMIS-auth-pipeline/job/master/lastSuccessfulBuild/artifact/erd-auth.zip`
      to
      `http://build.openlmis.org/job/OpenLMIS-auth-pipeline/job/master/323/artifact/erd-auth.zip`
   1. To make your new version visible in the "version" dropdown on ReadTheDocs, it has to be set as
      "active" in the admin settings on readthedocs (admin -> versions -> choose active versions). Once
      set active the link is displayed on the documentation page (it is also possible to set default
      version).
1. Create a branch of **openlmis-contract-tests** named by the tag (e.g. v3.3.0) and update **.env**
   file to include newly released components.
1. Update **.env** in **openlmis-deployment** for the Demo v3 deployment script with the release
   chosen which is at https://github.com/OpenLMIS/openlmis-deployment/blob/master/deployment/demo_env/.env
   1. Make sure to coordinate with the OpenLMIS Community Manager when redeploying to Demo v3.
   1. For each of the services deployed as a the new version on DockerHub, update the version in the
      **.env** file to the version you're releasing.
   1. Commit this change. (You do not need to tag this repo because it is only used by Jenkins, not
      external users.)
1. Kick off the **OpenLMIS-3.x-deploy-to-demo-v3** job on Jenkins
   1. **Confirm** Demo v3 has each deployed service. e.g. for the auth service:
      https://demo-v3.openlmis.org/auth check that the **version** is the one chosen.
1. Navigate to demo-v3.openlmis.org and ensure it works
1. Activate the released version on ReadTheDocs.io. To do so, log in on ReadTheDocs as a user with admin permissions to the OpenLMIS project, go to versions and find the desired branch under "Activate a version". ReadTheDocs may take a couple of minutes to discover the branch after creating it. Click activate next to the branch name once you find it (you can also use filtering to speed it up).

Once all these steps are completed and verified, the release process is complete. At this point you
can conduct communication tasks such as sharing the URL and Release Announcement to stakeholders.
Congratulations!
