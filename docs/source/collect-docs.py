import urllib

urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-requisition/master/README.md", "developer-docs/requisition.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-auth/master/README.md", "developer-docs/auth.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-template-service/master/README.md", "developer-docs/templateService.md")
urllib.urlretrieve("https://raw.githubusercontent.com/OpenLMIS/openlmis-template-service/master/STYLE-GUIDE.md", "developer-docs/codeStyleguide.md")

