targetScope = 'subscription'

param sqlAdminUsername string = 'bmoore'

param keyVaultResourceGroup string = 'VaultsGroup'
param keyVaultName string = 'armdemovault'
param keyVaultSecretName string = 'adminPassword'

param location string = deployment().location

resource kv 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(subscription().subscriptionId, keyVaultResourceGroup)
  name: keyVaultName
}

resource sqlResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'shared-sql'
  location: location
}

resource webResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'shared-web'
  location: location
}

module sqlDeployment 'modules/shared-sql.bicep' = {
  scope: sqlResourceGroup
  name: 'sqlDeployment'
  params: {
    sqlAdminUsername: sqlAdminUsername
    sqlAdminPassword: kv.getSecret(keyVaultSecretName)
    location: location
  }
}

module webDeployment 'modules/shared-web.bicep' = {
  scope: webResourceGroup
  name: 'webDeployment'
  params: {
    location: location
   }
}
