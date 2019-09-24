# Azure Virtual Machine with PowerShell DSC installing a file on the VM

This sample shows:
- How to use the custom script extension to install a file onto the VM from the staged folder in Azure storage, protected by a sasToken generated at deployment time. By default, it installs the file in /staging on the VM
- How to use PowerShell or the CLI to "stage" artifacts into Azure storage for deployment
    - So you don't have to use a public github url
    
