param appPrefix string
param environment string = 'DEV'
param location string = 'eastus'

param longAppName string
param shortAppName string
param runDateTime string = utcNow()

param translationServiceKey string
param speachServiceKey string

param dockerRegistryServerUrl string
param dockerRegistryServerUserName string
@secure()
param dockerRegistryServerPassword string

var eventGridConnectionName = '${lowerAppPrefix}-azureeventgrid-${shortAppName}-${environment}'

var functionStorageName = '${lowerAppPrefix}${shortAppName}fn${environment}'
var functionsAppName = '${lowerAppPrefix}-${longAppName}-fn-${environment}'


// --------------------------------------------------------------------------------
var deploymentSuffix = '-${runDateTime}'
var lowerAppPrefix = toLower(appPrefix)

// --------------------------------------------------------------------------------
module eventGridConnectionModule 'eventgridconnection.bicep' = {
  name: 'azureeventgridconnection'
  params: {
    connectionName: eventGridConnectionName
    location: location
  }
}

module blobStorageAccountModule 'storageaccount.bicep' = {
  name: 'storage${deploymentSuffix}'
  params: {
    storageSku: 'Standard_LRS'

    lowerAppPrefix: lowerAppPrefix
    longAppName: longAppName
    shortAppName: shortAppName
    environment: environment
    location: location
    runDateTime: runDateTime
  }
}

module logAnalyticsModule 'log-analytics.bicep' = {
  name: 'logAnalytics${deploymentSuffix}' 
  params: {
    lowerAppPrefix: lowerAppPrefix
    longAppName: longAppName
    environment: environment
    location: location
    runDateTime: runDateTime
  }
}

module functionModule 'function.bicep' = {
  name: 'function${deploymentSuffix}' 
  params: {
    functionName: functionsAppName
    functionStorageName: functionStorageName
    location: location
    fileStorageAcountName: blobStorageAccountModule.outputs.name
    dockerRegistryServerUrl: dockerRegistryServerUrl
    dockerRegistryServerUserName: dockerRegistryServerUserName
    dockerRegistryServerPassword: dockerRegistryServerPassword
  }
}

module logicAppServiceModule 'logic-app-service.bicep' = {
  name: 'logicappservice${deploymentSuffix}'
  params: {
    logwsid: logAnalyticsModule.outputs.id
    blobStorageConnectionString: blobStorageAccountModule.outputs.blobStorageConnectionString
    blobStorageAccountName: blobStorageAccountModule.outputs.name
    translationServiceKey: translationServiceKey
    speachServiceKey: speachServiceKey

    eventGridConnectionRuntimeUrl: eventGridConnectionModule.outputs.connectionRuntimeUrl
    eventGridConnectionName: eventGridConnectionName

    functionsAppName: functionsAppName
    functionsAppUrl: '${functionModule.outputs.functionsAppUrl}/MP3ToWAV'
    functionsAppKey: functionModule.outputs.functionsAppKey
    
    lowerAppPrefix: lowerAppPrefix
    longAppName: longAppName
    shortAppName: shortAppName
    environment: environment
    location: location
  }
}

module connectionsModule 'connections.bicep' = {
  name: 'connections${deploymentSuffix}' 
  params: {
    eventGridConnectionName: eventGridConnectionName
    logicAppServiceName: logicAppServiceModule.outputs.name
    location: location
    managedIdentityPrincipalId: logicAppServiceModule.outputs.managedIdentityPrincipalId
    blobStorageAccountId: blobStorageAccountModule.outputs.id
    blobStorageAccountName: blobStorageAccountModule.outputs.name
  }
}
