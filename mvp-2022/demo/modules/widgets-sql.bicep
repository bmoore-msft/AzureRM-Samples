
param serverName string = 'sql-${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location

resource db 'Microsoft.Sql/servers/databases@2021-05-01-preview' = {
  name: '${serverName}/widgets'
  location: location
}

