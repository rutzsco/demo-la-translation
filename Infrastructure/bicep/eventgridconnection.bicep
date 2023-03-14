param connectionName string
param location string = resourceGroup().location

resource connection 'Microsoft.Web/connections@2016-06-01' = {
    name: connectionName
    location: location
    kind: 'V2'
    properties: {
      displayName: connectionName
      customParameterValues: {}
      api: {
        id: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/azureeventgrid'
      }
    }
  }

var connectionRuntimeUrl = reference(connection.id, connection.apiVersion, 'full').properties.connectionRuntimeUrl
output connectionRuntimeUrl string = connectionRuntimeUrl
