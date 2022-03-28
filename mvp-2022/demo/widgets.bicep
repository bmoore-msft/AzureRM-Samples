targetScope = 'subscription'

param location string = deployment().location
param sharedSqlResourceGroup string = 'shared-sql'
param sharedWebResourceGroup string = 'shared-web'

module sqlDeployment 'modules/widgets-sql.bicep' = {
  scope: resourceGroup(sharedSqlResourceGroup)
  name: 'widgetSqlDeployment'
  params: {
    location: location
   }
}

module webDeployment 'modules/widgets-web.bicep' = {
  scope: resourceGroup(sharedWebResourceGroup)
  name: 'webDeployment'
  params: {
    location: location
   }
}
