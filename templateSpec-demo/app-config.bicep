
var networkConfig = {
  dev: {
    vnetName: 'dev-net'
    vnetAddressPrefixes: [ 
      '8.0.0.0/16'
    ]
    subnets: [
      {
        subnetName: 'dev-subnet1'
        addressPrefix: '8.0.0.0/24'
      }
      {
        subnetName: 'dev-subnet2'
        addressPrefix: '8.0.1.0/24'
      }
    ]
  }
  test: {
    vnetName: 'test-net'
    vnetAddressPrefixes: [
      '9.0.0.0/16'
    ]
    subnets: [
      {
        subnetName: 'test-subnet1'
        addressPrefix: '9.0.0.0/24'
      }
      {
        subnetName: 'test-subnet2'
        addressPrefix: '9.0.1.0/24'
      }
    ]

  }
  prod: {
    vnetName: 'prod-net'
    vnetAddressPrefixes: [
      '10.0.0.0/16'
    ]
    subnets: [
      {
        subnetName: 'prod-subnet1'
        addressPrefix: '10.0.0.0/24'
      }
      {
        subnetName: 'prod-subnet2'
        addressPrefix: '10.0.1.0/24'
      }
    ]
  }
}

resource configStore 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' = {
  name: 'tenant-config-store'
  location: resourceGroup().location
  sku: {
    name: 'standard'
  }
}

resource networkKeyValue 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-03-01-preview' = {
  parent: configStore
  name: 'networkConfig'
  properties: {
    value: string(networkConfig)
    //contentType: 'application/vnd.microsoft.appconfig.ff+json;charset=utf-8'
  }
}
