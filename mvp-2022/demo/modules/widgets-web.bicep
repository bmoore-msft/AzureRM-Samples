
param appServicePlanName string = 'shared-app-service'

param widgetWebSiteName string = 'widget-${uniqueString(resourceGroup().id)}'

param location string = resourceGroup().location

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' existing = {
  scope: resourceGroup('shared-web')
  name: appServicePlanName
}

resource webApplication 'Microsoft.Web/sites@2021-02-01' = {
  name: widgetWebSiteName
  location: location
  tags: {
    'hidden-related:${appServicePlan.id}': 'Resource'
  }
  properties: {
    serverFarmId: appServicePlan.id
  }
}
