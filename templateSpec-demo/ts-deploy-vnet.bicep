// this is the main template used for creating the templateSpec
// Note that the config for the network must already exists before *deploying* an instance of the templateSpec (app-config.bicep)

targetScope = 'subscription'

@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

var keyObj = {
  key: 'networkConfig'
}

// this can be static or parameters passed in to select the store
resource appConfigStore 'Microsoft.AppConfiguration/configurationStores@2021-03-01-preview' existing = {
  scope: resourceGroup('demo-config')
  name: 'tenant-config-store'
}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'demo-network-${environment}'
  location: deployment().location
}

module deployVnet 'vnet-module.bicep' = {
  scope: rg
  name: 'vnet-deployment'
  params: {
    networkConfig: json(appConfigStore.listKeyValue('2019-10-01', keyObj).value)[environment]
  }
}
