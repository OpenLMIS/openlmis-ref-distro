# Contributing to OpenLMIS

By contributing to OpenLMIS, you can help bring life-saving medicines to low- and middle-income countries.
The OpenLMIS community welcomes open source contributions. Before you get started, take a moment to review this
Contribution Guide, [get to know the community](https://openlmis.org/about/community/) and join in on the
[developer forum](https://groups.google.com/forum/#!forum/openlmis-dev).

The sections below describe all kinds of contributions, from bug reports to contributing code and translations.

## Reporting Bugs

The OpenLMIS community uses JIRA for [tracking bugs](https://openlmis.atlassian.net/projects/OLMIS/issues/).
This system helps track current and historical bugs, what work has been done, and so on. Reporting a bug with this
tool is the best way to get the bug fixed quickly and correctly.

### Before you report a bug

* Search to see if the same bug or a similar one has already been reported. If one already exists, it saves
you time in reporting it again and the community from investigating it twice. You can add comments or explain
what you are experiencing or advocate for making this bug a high priority to fix quickly.
* If the bug exists but has been closed, check to see which version of OpenLMIS it was fixed on (the Fix Version in
JIRA) and which version you are using. If it is fixed in a newer version, you may want to upgrade. If you cannot
upgrade, you may need to ask on the technical forums.
* If the bug does not appear to be fixed, you can add a comment to ask to re-open the bug report or file a new one.

### Reporting a new bug

Fixing bugs is a time-intensive process. To speed things along and assist in fixing the bug, it greatly helps to send
in a complete and detailed bug report. These steps can help that along:

1. First, make sure you search for the bug! It takes a lot of work to report and investigate bug reports, so please do
this first (as described in the section Before You Report a Bug above).
2. In the Description, write a clear and concise explanation of what you entered and what you saw, as well as what you
thought you should see from OpenLMIS.
3. Include the detailed steps, such as the Steps in the example below, that someone unfamiliar with the bug can use to
recreate it. Make sure this bug occurs more than once, perhaps on a different personal computer or web browsers.
4. The web browser (e.g. Firefox), version (e.g. v48), OpenLMIS version, as well as any custom modifications made.
5. Your priority in fixing this bug
6. If applicable, any error message text, stack trace, or logging output
7. If possible and relevant, a sample or view of the database - though don't post sensitive information in public

### Example Bug Report

```
Requisition is not being saved
OpenLMIS v3.0, Postgres 9.4, Firefox v48, Windows 10

When attempting to save my in-progress Requisition for the Essential Medicines program for the reporting period of Jan 2017,
I get an error at the bottom of the screen that says "Whoops something went wrong".

Steps:

1. log in

2. go to Requistions->Create/Authorize

3. Select My Facility (Facility F3020A - Steinbach Hospital)

4. Select Essential Medicines Program

5. Select Regular type

6. Click Create for the Jan 2017 period

7. Fill in some basic requested items, or not, it makes no difference in the error

8. Click the Save button in the bottom of the screen

9. See the error in red at the bottom. The error message is "Whoops something went wrong".

I expected this to save my Requisition, regardless of completion, so that I may resume it later.

Please see attached screenshots and database snapshot.
```

## Contributing Code

The OpenLMIS community welcomes code contributions and we encourage you to fix a bug or implement a new feature.  

### Coordinating with the Global Community

In reviewing contributions, the community promotes features that meet the broad needs of many countries for
inclusion in the global codebase. We want to ensure that changes to the shared, global code will not
negatively impact existing users and existing implementations. We encourage country-specific customizations to
be built using the extension mechanism. Extensions can be shared as open source projects so that other countries
might adopt them.

To that end, when considering coding a new feature or modification, please:

1. Review your feature idea with the [Product Committee](https://openlmis.atlassian.net/wiki/display/OP/Product+Committee).
They may help inform you about how other country needs overlap or differ. They may also consider including a new
feature in the global codebase using the [New Feature Verification Process](https://openlmis.atlassian.net/wiki/display/OP/New+Feature+Verification+Process)
or reviewing the [Global vs. Project-Specific Features wiki](https://openlmis.atlassian.net/wiki/display/OP/Global+vs.+Project-Specific+Features).
2. Before modifying or extending core functionality, email the [developer forum](https://groups.google.com/forum/#!forum/openlmis-dev)
or contact the [Technical Committee](https://openlmis.atlassian.net/wiki/display/OP/Technical+Committee).
They can help share relevant resources or create any needed extension points (further details below).

### Extensibility and Customization

A prime focus of version 3 is enabling extensions and customizations to happen without forking the codebase.

There are multiple ways OpenLMIS can be extended, and lots of documentation and starter code is available:

* The Reference UI supports extension by adding CSS, overriding HTML layouts, adding new screens, or replacing
existing screens in the UI application. See the [UI Extension Architecture and Guide](https://github.com/OpenLMIS/openlmis-requisition-refUI/blob/master/docs/extention_guide.md).
* The Reference Distribution is a collection of collaborative **Services**, Services may be added in
 or swapped out to create custom distributions.
* The Services can be extended using **extension points** in the Java code. The core team is eager to add more
extension points as they are requested by implementors. For documentation about this extension mechanism, see
these 3 READMEs: [openlmis-example-extensions README](https://github.com/OpenLMIS/openlmis-example-extensions/blob/master/README.md), [openlmis-example-extension module README](https://github.com/OpenLMIS/openlmis-example-extension/blob/master/README.md), and [openlmis-example service README](https://github.com/OpenLMIS/openlmis-example/blob/master/README.md#extension-points-and-extension-modules).
* Extra Data allows for clients to add additional data to RESTful resources so that the internal
storage mechanism inside a Service doesn't need to be changed.
* Some features may require both API and UI extensions/customizations. The Technical Committee worked on a [Requisition Splitting Extension Scenario](https://openlmis.atlassian.net/wiki/display/OP/Requisition+Splitting+-+Extension+Scenario+Analysis)
that illustrates how multiple extension techniques can be used in parallel.

To learn more about the OpenLMIS extension architecture and use cases, see: [https://openlmis.atlassian.net/wiki/x/IYAKAw](https://openlmis.atlassian.net/wiki/x/IYAKAw).

#### Extension Points

To avoid forking the codebase, the OpenLMIS community is committed to providing **extension points** to enable anyone
to customize and extend OpenLMIS. This allows different implementations to share a common global codebase, contribute
bug fixes and improvements, and stay up-to-date with each new version as it becomes available.

Extension points are simply hooks in the code that enable some implementations to extend the system with different
behavior while maintaining compatibility for others. The Dev Forum or Technical Committee group can help advise how
best to do this. They can also serve as a forum to request an extension point.

### Developing A New Service

OpenLMIS 3 uses a microservice architecture, so more significant enhancements to the system may be achieved by
creating an additional service and adding it in to your OpenLMIS instance. See the
[Template Service](https://github.com/OpenLMIS/openlmis-template-service) for an example to get started.

### What's not accepted

* Code that breaks the build or disables / removes needed tests to pass
* Code that doesn't pass our Quality Gate - see the [Style Guide](https://github.com/OpenLMIS/openlmis-template-service/blob/master/STYLE-GUIDE.md)
and [Sonar](http://sonar.openlmis.org/).
* Code that belongs in an Extension or a New Service
* Code that might break existing implementations - the software can evolve and change, but the
 community needs to know about it first!

## Git, Branching & Pull Requests

The OpenLMIS community employs several code-management techniques to help develop the software, enable contributions,
discuss & review and pull the community together. The first is that OpenLMIS code is managed using Git and is always 
publicly hosted on [GitHub](http://github.com/OpenLMIS/). We encourage everyone working on the codebase to 
take advantage of GitHub's fork and pull-request model to track what's going on. 

**TODO**: More guidance on working on a micro-service team with fork/pull-requests is forthcoming.  
It's important to communicate your development effort on the dev forum and always work toward 
the next release.

The general flow:

1. *Communicate* using JIRA, the wiki, or the developer forum!

2. *Fork* the relevant OpenLMIS project on GitHub

3. *Branch* from the `master` branch to do your work

4. *Commit* early and often to your branch

5. *Re-base* your branch *often* from OpenLMIS `master` branch - keep up to date!

6. Issue a *Pull Request* back to the `master` branch - explain what you did and keep it brief to speed review! 
Mention the JIRA ticket number (e.g., "OLIMS-34") in the commit and pull request messages to activate the 
JIRA/GitHub integration.

While developing your code, be sure you follow the [Style Guide](https://github.com/OpenLMIS/openlmis-template-service/blob/master/STYLE-GUIDE.md)
and keep your contribution specific to doing one thing.

## Automated Testing

OpenLMIS 3 includes new [patterns and tools](https://github.com/OpenLMIS/openlmis-template-service/blob/master/TESTING.md) 
for automated test coverage at all levels. Unit tests continue to be
the foundation of our automated testing strategy, as they were in previous versions of OpenLMIS. Version 3
introduces a new focus on integration tests, component tests, and contract tests (using Cucumber). Test
coverage for unit and integration tests is being tracked automatically using Sonar. Check the status of test
coverage at: [http://sonar.openlmis.org/](http://sonar.openlmis.org/). New code is expected to have test
coverage at least as good as the existing code it is touching.

## Continuous Integration, Continuous Deployment (CI/CD) and Demo Systems

Continuous Integration and Deployment are heavily used in OpenLMIS. Jenkins is used to automate builds and
deployments trigged by code commits. The CI/CD process includes running automated tests, generating ERDs,
publishing to Docker Hub, deploying to Test and UAT servers, and more. Furthermore, documentation of these build
pipelines allows any OpenLMIS implementation to clone this configuration and employ CI/CD best practices for
their own extensions or implementations of OpenLMIS.

See the status of all builds online: [http://build.openlmis.org/](http://build.openlmis.org/)

Learn more about OpenLMIS CI/CD on the wiki: [CI/CD Documentation](https://openlmis.atlassian.net/wiki/pages/viewpage.action?pageId=87195734)

## Language Translations & Localized Implementations

OpenLMIS 3 has translation keys and strings built into each component, including the API services and UI
components. The community is encouraging the contribution of translations using Transifex, a tool to manage
the translation process. Because of the micro-service architecture, each component has its own translation file
and its own Transifex project.

See the [OpenLMIS Transifex projects](https://www.transifex.com/openlmis/public/) and the
[Translations wiki](https://openlmis.atlassian.net/wiki/display/OP/Translations) to get started.

## Licensing

OpenLMIS code is licensed under an open source license to enable everyone contributing to the codebase and the
community to benefit collectively. As such all contributions have to be licensed using the OpenLMIS license to be
accepted; no exceptions. Licensing code appropriately is simple:

### Modifying existing code in a file

* Add your name or your organization's name to the license header. e.g. if it reads `copyright VillageReach`, update it
to `copyright VillageReach, <insert name here>`
* Update the copyright year to a range. e.g. if it was 2016, update it to read 2016-2017

### Adding new code in a new file

* Copy the license file header template, [LICENSE-HEADER](LICENSE-HEADER), to the top of the new file.
* Add the year and your name or your organization's name to the license header. e.g. if it reads `Copyright © <INSERT YEAR AND COPYRIGHT HOLDER HERE>`, update it to `Copyright © 2017 MyOrganization`

For complete licensing details be sure to reference the LICENSE file that comes with this project.

## Feature Roadmap

The Living Roadmap can be found here: https://openlmis.atlassian.net/wiki/display/OP/Living+Product+Roadmap
The backlog can be found here: https://openlmis.atlassian.net/secure/RapidBoard.jspa?rapidView=46&view=planning.nodetail

## Contributing Documentation

Writing documentation is just as helpful as writing code. See [Contribute Documentation](http://docs.openlmis.org/en/latest/developer-docs/contributeDocs.html).

## References

* Developer Documentation (ReadTheDocs) - [http://docs.openlmis.org/](http://docs.openlmis.org/)

* Developer Guide (in the wiki) - [https://openlmis.atlassian.net/wiki/display/OP/Developer+Guide](https://openlmis.atlassian.net/wiki/display/OP/Developer+Guide)

* Architecture Overview (v3) - [https://openlmis.atlassian.net/wiki/pages/viewpage.action?pageId=51019809](https://openlmis.atlassian.net/wiki/pages/viewpage.action?pageId=51019809)

* API Docs - [http://docs.openlmis.org/en/latest/api](http://docs.openlmis.org/en/latest/api)

* Database ERD Diagrams - [http://docs.openlmis.org/en/latest/erd/](http://docs.openlmis.org/en/latest/erd/)

* GitHub - [https://github.com/OpenLMIS/](https://github.com/OpenLMIS/)

* JIRA Issue & Bug Tracking - [https://openlmis.atlassian.net/projects/OLMIS/issues](https://openlmis.atlassian.net/projects/OLMIS/issues)

* Wiki - [https://openlmis.atlassian.net/wiki/display/OP](https://openlmis.atlassian.net/wiki/display/OP)

* Developer Forum - [https://groups.google.com/forum/#!forum/openlmis-dev](https://groups.google.com/forum/#!forum/openlmis-dev)

* Release Process (using Semantic Versioning) - [https://openlmis.atlassian.net/wiki/display/OP/Releases](https://openlmis.atlassian.net/wiki/display/OP/Releases)

* OpenLMIS Website - [https://openlmis.org](https://openlmis.org)

