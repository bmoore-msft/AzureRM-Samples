# Azure Resource Manager Samples

This repo has a handful of scenario based samples for using Azure Resource Manager Templates

Run the script and point the script to the folder for the sample you want to deploy.  For example:

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ResourceGroupName '[foldername]'
```
If your sample has artifacts that need to be "staged" for deployment (Configuration Scripts, Nested Templates, DSC Packages) then add a storage account parameter to the command.  Note the storage account must already exist within the subscription.  Think of this a "temp" storage for AzureRM.

```PowerShell
.\Deploy-AzureResourceGroup.ps1 -ResourceGroupLocation 'eastus' -ResourceGroupName 'NestedSample' -UploadArtifacts 
```

