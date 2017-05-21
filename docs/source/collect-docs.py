import urllib

#architecture
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/dev-ui/master/docs/application_structure.md", "architecture/applicationStructure.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/dev-ui/master/docs/build_process.md", "architecture/buildProcess.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/dev-ui/master/docs/extention_guide.md", "architecture/extentionGuide.md")

#components
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-fulfillment/master/README.md", "components/fulfillmentService.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-requisition/master/README.md", "components/requisitionService.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-auth/master/README.md", "components/authService.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-referencedata/master/README.md", "components/referencedataService.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-stockmanagement/master/README.md", "components/stockmanagementService.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-template-service/master/README.md", "components/templateServiceService.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-reference-ui/master/README.md", "components/referenceUI.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-auth-ui/master/README.md", "components/authUI.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-referencedata-ui/master/README.md", "components/referencedataUI.md")

#conventions
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-template-service/master/STYLE-GUIDE.md", "conventions/codeStyleguide.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-template-service/master/TESTING.md", "conventions/testing.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-template-service/master/ERROR_HANDLING.md", "conventions/errorHandling.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/dev-ui/master/docs/coding_conventions.md", "conventions/uiCodeConventions.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/dev-ui/master/docs/styleguide.md", "conventions/uiStyleguide.md")

# deployment
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-deployment/master/deploymentTopology.md", "deployment/topology.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-deployment/master/provision/Provision-single-host.md", "deployment/provisionSingleHost.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-deployment/master/provision/Provision-swarm-With-ELB.md", "deployment/provisionSwarmWithELB.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-deployment/master/provision/Provision-swarm-With-Elastic-ip.md", "deployment/provisionSwarmWithElasticIp.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-deployment/master/deployment/README.md", "deployment/demoAndCiJenkins.md")

# contribute
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-template-service/master/LICENSE-HEADER.md", "conventions/licenseHeader.md")
