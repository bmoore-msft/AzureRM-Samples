
param appServicePlanName string = 'shared-app-service'

param adminWebSiteName string = 'admin-${uniqueString(resourceGroup().id)}'

param location string = resourceGroup().location

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'F1'
    capacity: 1
  }
}

resource webApplication 'Microsoft.Web/sites@2021-02-01' = {
  name: adminWebSiteName
  location: location
  tags: {
    'hidden-related:${appServicePlan.id}': 'Resource'
  }
  properties: {
    serverFarmId: appServicePlan.id
  }
}
