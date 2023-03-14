param functionName string
param functionStorageName string
param location string = resourceGroup().location

param sku string = 'EP1'

param dockerRegistryServerUrl string
param dockerRegistryServerUserName string
@secure()
param dockerRegistryServerPassword string

param fileStorageAcountName string

// Storage account for file upload
resource fileStorageAccountResource 'Microsoft.Storage/storageAccounts@2021-04-01' existing = { name: fileStorageAcountName }

// --------------------------------------------------------------------------------
// Storage account for the service
resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: functionStorageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

resource appServicePlan 'Microsoft.Web/serverFarms@2020-06-01' = {
  name: functionName
  location: location
  sku: {
    name: sku
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

resource azureFunction 'Microsoft.Web/sites@2020-12-01' = {
  name: functionName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/azure-functions/dotnet:3.0-appservice-quickstart'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: dockerRegistryServerUrl
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: dockerRegistryServerUserName
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: dockerRegistryServerPassword
        }
        {
          name: 'STORAGE_ACCOUNT_KEY'
          value: listKeys(fileStorageAccountResource.id, fileStorageAccountResource.apiVersion).keys[0].value
        }
        {
          name: 'STORAGE_ACCOUNT_NAME'
          value: fileStorageAcountName
        }
      ]
    }
  }
}
var defaultHostKey = listkeys('${azureFunction.id}/host/default', '2016-08-01').functionKeys.default

output functionsAppUrl string = 'https://${azureFunction.properties.defaultHostName}/api'
output functionsAppKey string = defaultHostKey
