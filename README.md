# Azure Resource Manager Samples

This repo has a handful of scenario based samples for using Azure Resource Manager Templates.  Also included are scripts that will deploy the template *and* any related artifacts
 (configuration scripts, nested templates) required for the template deployment.

These scripts are similar to the script used by the Azure SDK in Visual Studio and follow the same model for parameterizing templates for staged artifacts.
The artifacts are copied to an Azure storage account and parameters are used for the uri's and sasToken. Special parameter names are used by each template
 (_artifactsLocation and _artifactsLocationSasToken) to indicate which paramter values will be set by the script. While these scripts and templates are 
 designed to work together, it is not required.  The templates will work just as well in other workflows, but those workflows would be required to stage 
 or upload the artifacts and set the appropriate parameter values.

So the script has 2 parts:
1) Uploading artifacts to storage and overriding parameter values in the template for the location and sasToken
2) Creating the resource group and deploying the template.


Run the script and point the script to the folder for the sample you want to deploy.  For example:

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory '[foldername]'
```
```bash
azure-group-deploy.sh -a [foldername] -l eastus -u
```
If your sample has artifacts that need to be "staged" for deployment (Configuration Scripts, Nested Templates, DSC Packages) then set the upload switch on the command.
You can optionally specify a storage account to use, if so the storage account must already exist within the subscription.  If you don't want to specify a storage account
one will be created by the script (think of this as "temp" storage for AzureRM) and reused by subsequent deployments.

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ArtifactsStagingDirectory 'NestedSample' -UploadArtifacts 
```
```bash
azure-group-deploy.sh -a nestedsample -l eastus -u
```
