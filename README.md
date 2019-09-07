# Azure Resource Manager Samples
This repo has a handful of scenario based samples for using Azure Resource Manager Templates.  Also included are scripts that will deploy the template *and* any related artifacts
 (configuration scripts, nested templates) required for the template deployment.

These scripts are the same scripts used in the [Azure QuickStart repo](https://github.com/Azure/azure-quickstart-templates) and the Azure SDK in Visual Studio (VS scripts are probably older) and follow the same model for parameterizing templates for staged artifacts.

The artifacts are copied to an Azure storage account and parameters are used for the uri's and sasToken. Special parameter names are used by each template (_artifactsLocation and _artifactsLocationSasToken) to indicate which parameter values will be set by the script. While these scripts and templates are designed to work together, it is not required.  The templates will work just as well in other workflows, but those workflows would be required to stage  or upload the artifacts and set the appropriate parameter values.

The scripts will deploy a resource group or subscription scoped template.

So the script has 2 parts:
1) Uploading artifacts to storage and providing parameter values in the template for the artifacts' location and sasToken
2) Creating the resource group (in a Resource Group Scoped Deployment) and deploying the template.

Run the script and point the script to the folder for the sample you want to deploy.  For example:

```PowerShell
.\Deploy-AzTemplate.ps1 -ArtifactsStagingDirectory '[foldername]' -Location 'eastus'
```
```bash
azure-group-deploy.sh -a [foldername] -l eastus
```
These scripts are also used in CICD pipelines just as they are on the command line which helps stream line the dev/test lifecycle.

