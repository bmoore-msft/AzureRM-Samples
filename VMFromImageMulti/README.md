# Multiple copies of an Azure Virtual Machine based on a user or custom vhd image.

This sample shows:
- How to deploy multiple copies of a VM using a custom VHD image.  Each will have it's own public IP address.  

Note that the storage account used for the source and destination image must be the same and in the same location as the VM - which uses the resource group location in this template.

Also note that if you want a VM size that uses premium storage, the storage account for the image must be using the premium sku.

    

