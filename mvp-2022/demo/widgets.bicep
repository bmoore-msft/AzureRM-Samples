targetScope = 'subscription'

param location string = deployment().location

module sqlDeployment 'modules/widgets-sql.bicep' = {
  scope: resourceGroup('shared-sql')
  name: 'widgetSqlDeployment'
  params: {
    location: location
   }
}

module webDeployment 'modules/widgets-web.bicep' = {
  scope: resourceGroup('shared-web')
  name: 'webDeployment'
  params: {
    location: location
   }
}
