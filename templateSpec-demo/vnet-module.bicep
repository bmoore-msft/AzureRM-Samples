@description('Virtual Network Configuration Object')
param networkConfig object

@description('Location for all resources.')
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: networkConfig.vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: networkConfig.vnetAddressPrefixes
    }
    subnets: [for subnet in networkConfig.subnets: {
      name: subnet.subnetName
      properties: {
        addressPrefix: subnet.addressPrefix
        //networkSecurityGroup, etc
      }
    }]
  }
}
