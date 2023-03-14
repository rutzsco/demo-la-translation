param location string = ''
param logicAppServiceName string = ''
param eventGridConnectionName string = ''
param managedIdentityPrincipalId string = ''
param blobStorageAccountName string = ''
param blobStorageAccountId string = ''

resource eventGridTopic 'Microsoft.EventGrid/systemTopics@2021-12-01'= {
  name: '${blobStorageAccountName}-systemTopic'
  location: location
  properties:{
    source: blobStorageAccountId
    topicType:'Microsoft.Storage.StorageAccounts'
  }
  identity:{
    type:'SystemAssigned'
  }
}

// --------------------------------------------------------------------------------
// API Access Policies ---------------------------------------------------------------------

resource apiAccessPolicy 'Microsoft.Web/connections/accessPolicies@2016-06-01' = {
  name: '${eventGridConnectionName}/${logicAppServiceName}'
  location: location
  properties: {
    principal: {
      type: 'ActiveDirectory'
      identity: {
        tenantId: subscription().tenantId
        objectId: managedIdentityPrincipalId
      }
    }
  }
}
