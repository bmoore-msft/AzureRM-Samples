# Azure Virtual Machine with PowerShell DSC installing a file on the VM

This sample shows:
- How to use a DSC to install a Web Deploy package that has been downloaded to the VM in C:\WindowsAzure
    - The DSC Script will:
        - Install IIS
        - Install Web Deploy
        - Download the Web Deploy package
        - Install the package on localhost
- How to use PowerShell or the CLI to "stage" artifacts into Azure storage for deployment
    - So you don't have to use a public github url
    
    

