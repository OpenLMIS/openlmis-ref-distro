# Contributing to OpenLMIS

By contributing to OpenLMIS, you can help bring life-saving medicines to low- and middle-income countries.
The OpenLMIS community welcomes open source contributions. Before you get started, take a moment to review this
Contribution Guide, [get to know the community](https://openlmis.org/about/community/) and join in on the
[developer forum](https://groups.google.com/forum/#!forum/openlmis-dev).

The sections below describe all kinds of contributions, from bug reports to contributing code and translations.

## Reporting Bugs

The OpenLMIS community uses JIRA for [tracking bugs](https://openlmis.atlassian.net/projects/OLMIS/issues/). All bugs must be submitted to the OLMIS project to be reviewed or worked on.
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

1. First, make sure you search for the bug in the current OpenLMIS backlog! It takes a lot of work to report and investigate bug reports, so please do this first (as described in the section Before You Report a Bug above).
2. Create a bug in the OpenLMIS Jira Project.  Include the following information in the ticket:
    1. _Type_: Select "bug"
    2. _Status_: Leave as "ROADMAP". The OpenLMIS team will update the status to "TO DO" once the ticket is ready for work and reproduced.
    3. _Description_: Write a clear and concise explanation of what you entered and what you saw, as well as what you
thought you should see from OpenLMIS. Include the detailed steps, such as the Steps in the example below, that someone unfamiliar with the bug can use to recreate it. Make sure this bug occurs more than once, perhaps on a different personal computer or web browsers. Indicate the web browser (e.g. Firefox), version (e.g. v48), OpenLMIS version, as well as any custom modifications made. Include any time sensitivities or information of impact to support the team in prioritizing the bug.
    4. _Priority_: Indicate the priority level based on the guidence below in the Prioritizing Bugs section. The priority may be updated later by the Product Manager upon grooming and scheduling for work.
    5. _Affects Version/s_: Indicate what version of the reference distribution the bug was found in.
    6. _Component_: If you know which service is impacted by the bug, please include. If not, leave it blank.
    7. _Attachments_: Attach any relevant screen shots, videos or documents that will help the team understand and reproduce the bug.
3. If applicable, include any error message text, a screenshot, stack trace, or logging output in the _Description_ or _Attachments_.
4. If possible and relevant, a sample or view of the database - though don't post sensitive information in public.

Once the bug is submitted, the OpenLMIS team will review the bugs prior to the next sprint cycle. Bugs will be prioritized and scheduled for work based on priority, resources, and implementation needs. Follow the ticket in Jira for updates on status and completion. Each release includes a list of bugs fixed.

### Prioritizing Bugs

Each bug submission should include an initial prioritization form the reporter. Please follow the guidelines below for the initial prioritization.

* **Blocker**: Cannot execute function (cannot click button, button does not exist, cannot complete action when button is clicked). Cannot complete expected action (does not match expected results for the test case). No error message when there is an error. OpenLMIS will not release with this bug.
* **Critical**: Error message is unactionable by the user, and user cannot complete next action (500 server error message). Search results provided do not match expected results based on data. Poor UI performance or accessibility (user cannot tab to column or use keyboard to complete action). OpenLMIS should not release with this bug.
* **Major**: Performance related (slow response time). Major asthetic issue (See [UI Styleguide](http://build.openlmis.org/job/OpenLMIS-ui-components-pipeline/job/master/lastSuccessfulBuild/artifact/build/styleguide/section-3.html#!#kssref-3-3) for reference). Incorrect filtering, but doesn't block users from completing tasks and executing functionality. Wrong user error message (user does not know how to proceed based on the error message provided).
* **Minor**: Aesthetics (spacing is wrong, alignment is wrong, see [UI Styleguide](http://build.openlmis.org/job/OpenLMIS-ui-components-pipeline/job/master/lastSuccessfulBuild/artifact/build/styleguide/section-3.html#!#kssref-3-3)). Message key is wrong. Console errors. Service giving the wrong error between services.
* **Trivial**: Anything else.

When the bug is groomed and scheduled for work, the Product Manager will set the final priority level. See [Backlog Grooming](https://openlmis.atlassian.net/wiki/spaces/OP/pages/106627250/Backlog+Grooming) for details on the scheduling of work.

#### Ticket exemplars

The bugs listed are examples of bugs for their priorities. When completing exploratory testing and bugs are found, consider these bugs as references for how to record and prioritize bugs.

**Blocker:**
* OLMIS-3983 - Cannot access offline requisition
* OLMIS-3509 - No error message when create user fails
* OLMIS-3501 - I can select a program that is not supported by My Facility on the Create/Initiate page
* OLMIS-2980 - Broken translations for Stock Management Adjustments page titles 
* OLMIS-3508 - Batch approval sticky rows do not respond to scrolling

**Critical:**
* OLMIS-4076 - It's possible to submit a requisition twice: duplicate status changes
* OLMIS-3500 - The black background is only the height of the window

**Minor:**
* OLMIS-3299 - Insufficient error message when submitting physical inventory with a future date
* OLMIS-2792 - Cannot add Issue for Essential Meds - demo data issue
* OLMIS-3987 - Long text not wrapped properly in modals
* OLMIS-3746 - Source Comments input field not displayed correctly on Firefox

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

The OpenLMIS community welcomes code contributions and we encourage you to implement a new feature. Review the following process and guidelines for contributing new features or modification to existing functionality.

### Coordinating with the Global Community

In reviewing your proposed contribution, the community promotes features that meet the broad needs of many countries for
inclusion in the global codebase. We want to ensure that changes to the shared, global code will not
negatively impact existing users and existing implementations. We encourage country-specific customizations to
be built using the extension mechanism. Extensions can be shared as open source projects so that other countries
might adopt them.

To that end, when considering coding a new feature or modification, please follow these steps to coordinate with the global community:

1. Create an OpenLMIS Jira ticket and include information for the following fields:
    1. _Type_: Select "New Feature"
    2. _Status_: Leave as "ROADMAP"
    3. _Summary_: One line description of the feature
    4. _Component/s_: If you know which service is impacted by the new feature, please include. If not, leave it blank.
    5. _Description_: Include the user story and detailed description of the feature. Highlight the end user value. Include user steps and edge cases if applicable. Attach screen shots or diagrams if useful.
    6. _Affects Version_: Leave it blank.
2. Send an email to the product committee listserv ([instructions](https://openlmis.atlassian.net/wiki/spaces/OP/pages/27000853/Community)) with the link to the Jira ticket and any additional information or context about the request. Please review the [Global vs. Project-Specific Features wiki](https://openlmis.atlassian.net/wiki/display/OP/Global+vs.+Project-Specific+Features) for details on how to evaluate if a feature is globally applicable or specific to an implementation. Please clearly indicate any time sensitivities so the product committee is aware and can be responsive.
3. The [Product Committee](https://openlmis.atlassian.net/wiki/display/OP/Product+Committee) will review the feature request at the next Product Committee meeting and provide feed back or request further clarification. Once the feature request is understood, the Product Committee will evaluate the request.
4. If the request is deemed globally applicable and acceptable for the global codebase, the Product Committee will provide any additional guidence or direction needed in preparation for the Technical Committee review.
5. Once approved by the product committee, we request the implementer to contact the [developer forum](https://groups.google.com/forum/#!forum/openlmis-dev) or contact the [Technical Committee](https://openlmis.atlassian.net/wiki/display/OP/Technical+Committee) to provide a proposed technical design to implement the approved feature. They can help share relevant resources or create any needed extension points (further details below).

### Extensibility and Customization

A prime focus of version 3 is enabling extensions and customizations to happen without forking the codebase.

There are multiple ways OpenLMIS can be extended, and lots of documentation and starter code is available:

* The Reference UI supports extension by adding CSS, overriding HTML layouts, adding new screens, or replacing
existing screens in the UI application. See the [UI Extension Guide](https://github.com/OpenLMIS/openlmis-ui-components/blob/master/docs/extension_guide.md#ui-extension-guide).
* The Reference Distribution is a collection of collaborative **Services**, Services may be added in
 or swapped out to create custom distributions.
* The Services can be extended using **extension points** in the Java code. The core team is eager to add more
extension points as they are requested by implementors. For documentation about this extension mechanism, see
these 3 READMEs: [openlmis-example-extensions README](https://github.com/OpenLMIS/openlmis-example-extensions/blob/master/README.md#openlmis-example-extensions), [openlmis-stockmanagement-validator-extension module README](https://github.com/OpenLMIS/openlmis-stockmanagement-validator-extension/blob/master/README.md#openlmis-stock-management-validator-extension-module), and [openlmis-example service README](https://github.com/OpenLMIS/openlmis-example/blob/master/README.md#openlmis-example-service).
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
  * In case developers expect they may not be able to fix Sonar/tests/build issues within a working day, breaking changes should be reverted.
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

The pull request should be on a short-lived branch and processed very quickly by reviews towards merging back
to the master branch. If there is more that one developer on the same short-lived branch,
then that branch is at risk of not being short-lived. It is at risk of being more and more like
a release branch under active development, and not short at all.

The branch may have received many commits before the developer initiated the pull
request, but it's important to remember about rebasing the changes with the master branch before creating it.
Otherwise, conflicts will not allow reviewer to merge the changes to the master branch.

OpenLMIS Jenkins runs build, test and Sonar analysis for all branches and also for pull requests.
For both, the developer needs to get the commit reviewed. In case of second of them, code review is happening
in the pull request itself. Build status makes the work easier for developers who create the pull requests and
those who are reviewing them, so they save the time and know the code is high quality.

As a developer working on a branch, you have Sonar check your work without that check effecting
the Sonar report on the master branch. SonarQube gives developers an opportunity to track the quality of
code branches to ensure that only clean, approved code gets merged into master, and when it's not
it doesn't mislead them looking at the master branch into thinking the overall project quality has dropped.

While creating pull request [Sonar](http://sonar.openlmis.org/) quality gates have to pass. Otherwise, the reviewer
wouldn't be able to merge the code to the master branch.

For more about version numbers and releasing, see **versioningReleasing.md**.

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

### Quality responsibilities
The changes made by the developer should be covered by automated tests which have to follow the [Testing Guide](https://openlmis.readthedocs.io/en/latest/conventions/testing.html).
The developers should make sure that all acceptance criteria are met and check whether their changes work before moving the ticket to QA.
They should cooperate with the QA person and give them some tips on how to verify changes that are difficult to test.
The developer should make the tester aware of potential issues or places that could be affected by their changes.

**DO:**
* cover changes by automated tests
* cover all acceptance criteria
* initial manual testing
* give important information
* cooperate with the QA
* give advice on how to test difficult changes
* warn about potential issues
                  
**DON'T:**
* leave changes without automated tests
* skip any of the acceptance criteria
* move changes to QA without any verification
* just assign the ticket to the QA
* snub questions
* leave the QA without any help
* conceal any gaps in the code

### Feature Flags

This is a mechanism that can reduce branching code and merging large pull requests when working on some big
functionality that is not finished. **Feature Flags** are based on branching the code execution based on status
of feature flag. We simply put old working code in one branch while our new implementation is placed in another.
This allows us to ommit using git branches and have our code on the master branch. Moreover this new code will be deployed
on our tests servers. **Feature Flag** status can be changed on deployment by setting an environment variable with proper name.

**Feature Flags** can be used in situations like:
* making an controversial change that could break other functionality
* making a potential performance improvement
* working on unfinished functionality on master branch
* marking functionality that can be turned on/off after releasing it (those should be documented)
All except for the last case should be rather short lived flags and be removed after few weeks.
Those **Feature Flags** give us advantage of possibility to verify changes and logs on test server rather than locally.

Here is an example of implementation for **BATCH_APPROVE_SCREEN feature flag** in our UI code:
* [Feature flag constant](https://github.com/OpenLMIS/openlmis-requisition-ui/blob/master/src/requisition-batch-approval/batch-approve-screen-flag.constant.js)
* [Run method for setting flag to our featureFlagService](https://github.com/OpenLMIS/openlmis-requisition-ui/blob/master/src/requisition-batch-approval/requisition-batch-approve.flag.run.js)
* [Example of feature flag usage](https://github.com/OpenLMIS/openlmis-requisition-ui/blob/master/src/requisition-approval/requisition-approval.routes.js#L70)

Here is an example of implementation for **FACILITY_SEARCH_CONJUNCTION feature flag** in our backend code:
* [Commit with new feature flag](https://github.com/OpenLMIS/openlmis-referencedata/commit/8aec45a2020e2628feaf4505645b89699314d2ab)

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
[Translations wiki](https://openlmis.atlassian.net/wiki/display/OP/Translations) to get started. See also the
[UI Extenion guide](http://docs.openlmis.org/en/latest/components/uiExtensionGuide.html#messages) for details
about how implementations can override UI strings with their own custom messages.

## Licensing

---
**NOTE**

licensing of a contribution here only applies for code that will be owned by the OpenLMIS' owner.  i.e. code that
lives in an official OpenLMIS Repository (e.g. https://github.com/openlmis or https://gitlab.com/openlmis).  
Contributions which utilize an extension mechanism, such a new Service that lives outside of an OpenLMIS
repository do not need to abide to this licensing section, as that contribution is more to the wider open source
community, than to the OpenLMIS project specifically.

---

OpenLMIS' code is licensed under an open source license to enable everyone contributing to the codebase and the
community to benefit collectively. As such all contributions must:

1. Sign the OpenLMIS' [Contributor Assignment Agreement][olmis-caa] (CAA), this gives the project flexibility.
   * With approval, a contributor may opt to sign a [Contributor License Agreement][olmis-cla] (CLA), this
     allows the contributor to retain copyright, while allowing the project license flexibility.
2. Submit your signed CAA or CLA to the OpenLMIS Governance Committee (todo: establish governance process).
3. Mark the appropriate copyright and license header using the OpenLMIS license (see below).
4. No exceptions.

[olmis-caa]: OpenLMIS-CAA-2021.pdf
[olmis-cla]: OpenLMIS-CLA-2021.pdf

### Modifying existing code in a file

If you signed a CAA:

* Retain the copyright mark, e.g. `Copyright © 2017 VillageReach`.
* Update the copyright year to a range. e.g. if it was 2016, update it to read 2016-2017

If you signed a CLA:

* Retain the existing copyright mark, e.g. `Copyright © 2017 VillageReach`, and add your own one line down:  `Copyright © <INSERT YEAR AND COPYRIGHT HOLDER HERE>`.
* Where `copyright holder` should likely read your organization's name.
* Where `year` is the current year.

### Adding new code in a new file

If you signed a CAA:

* Copy the license file header template, [LICENSE-HEADER](https://github.com/OpenLMIS/openlmis-ref-distro/blob/master/LICENSE-HEADER), to the top of the new file.
* Where it says `Copyright © <INSERT YEAR AND COPYRIGHT HOLDER HERE>`, insert `VillageReach`.
* Update the copyright year to the current year.

If you signed a CLA:

* Copy the license file header template, [LICENSE-HEADER](https://github.com/OpenLMIS/openlmis-ref-distro/blob/master/LICENSE-HEADER), to the top of the new file.
* Add the year and your name or your organization's name to the license header. e.g. if it reads `Copyright © <INSERT YEAR AND COPYRIGHT HOLDER HERE>`, update it to `Copyright © 2017 MyOrganization`

For complete licensing details be sure to reference the LICENSE file that comes with this project.

## Feature Roadmap

The Living Roadmap can be found [here](https://openlmis.atlassian.net/wiki/display/OP/Living+Product+Roadmap)
The backlog can be found [here](https://openlmis.atlassian.net/secure/RapidBoard.jspa?rapidView=46&view=planning.nodetail)

### Suggest a New Feature

The OpenLMIS community welcomes suggestions and requests for new features, functionality or improvements to OpenLMIS. __Please note that suggested new features may or may not be scheduled for work depending on resourcing and value to the community. If this feature is needed for a specific implementation in a timely fashion we suggest the team consider building the feature and contributing it back to core. See the section on Contributing Code above for details.__  Follow the steps below so that the community can review, evaluate, and potentially schedule the new feature for work:

1. Create an OpenLMIS Jira ticket and include information for the following fields:
    1. _Type_: Select "New Feature"
    2. _Status_: Leave as "ROADMAP"
    3. _Summary_: One line description of the feature
    4. _Component/s_: If you know which service is impacted by the new feature, please include. If not, leave it blank.
    5. _Description_ Include the user story and detailed description of the desired new feature, functionality or improvement. Highlight the end user value. Include user steps and edge cases if applicable. Attach screen shots or diagrams if useful in building a shared understanding of the suggested feature.
    6. _Affects Version_: Leave it blank.
2. Send an email to the product committee listserv ([instructions](https://openlmis.atlassian.net/wiki/spaces/OP/pages/27000853/Community)) with the link to the Jira ticket and any additional information or context about the suggested feature and functionality. Please review the [Global vs. Project-Specific Features wiki](https://openlmis.atlassian.net/wiki/display/OP/Global+vs.+Project-Specific+Features) for details on how to evaluate if a feature is globally applicable or specific to an implementation. Please clearly indicate any time sensitivities so the product committee is aware and can be responsive.  
3. The [Product Committee](https://openlmis.atlassian.net/wiki/display/OP/Product+Committee) will review the feature request at the next Product Committee meeting and provide feed back or request further clarification. Once the feature request is understood, the Product Committee will evaluate the request to determine the next steps.
    * The Product Committee will set the priority of the feature and keep the Jira ticket updated with information on scheduling, questions, and if any additional information is needed.
4. Follow the ticket in Jira or attend Product Committee meetings to keep updated on the status of the suggested new feature.

## Contributing Documentation

Writing documentation is just as helpful as writing code. See [Contribute Documentation](http://docs.openlmis.org/en/latest/contribute/contributeDocs.html).

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
