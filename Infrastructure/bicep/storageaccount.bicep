// --------------------------------------------------------------------------------
// Create storage account
// --------------------------------------------------------------------------------
param lowerAppPrefix string = 'myorgname'
param shortAppName string = 'demola'
param longAppName string = ''
@allowed([ 'dev', 'demo', 'qa', 'stg', 'prod' ])
param environment string = 'dev'
param location string = resourceGroup().location
param runDateTime string = utcNow()

@allowed([ 'Standard_LRS', 'Standard_GRS', 'Standard_RAGRS' ])
param storageSku string = 'Standard_LRS'

// --------------------------------------------------------------------------------
var templateFileName = '~storageAccount.bicep'
var storageAccountName = '${lowerAppPrefix}${shortAppName}blob${environment}'

// --------------------------------------------------------------------------------
resource storageAccountResource 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: storageAccountName
    location: location
    sku: {
        name: storageSku
    }
    tags: {
        LastDeployed: runDateTime
        TemplateFile: templateFileName
        AppPrefix: lowerAppPrefix
        AppName: longAppName
        Environment: environment
    }
    kind: 'StorageV2'
    properties: {
        accessTier: 'Hot'
        allowBlobPublicAccess: true
        supportsHttpsTrafficOnly: true
        minimumTlsVersion: 'TLS1_2'
    }
}

// --------------------------------------------------------------------------------
resource audiodownloadBlobContainerResource 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
    name: '${storageAccountResource.name}/default/audiodownload'
    properties: {}
}

resource audiouploadBlobContainerResource 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
    name: '${storageAccountResource.name}/default/audioupload'
    properties: {}
}

resource exceldownloadBlobContainerResource 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
    name: '${storageAccountResource.name}/default/exceldownload'
    properties: {}
}
resource exceluploadBlobContainerResource 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
    name: '${storageAccountResource.name}/default/excelupload'
    properties: {}
}
resource textdownloadBlobContainerResource 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
    name: '${storageAccountResource.name}/default/textdownload'
    properties: {}
}
resource textuploadBlobContainerResource 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
    name: '${storageAccountResource.name}/default/textupload'
    properties: {}
}

resource blobServiceResource 'Microsoft.Storage/storageAccounts/blobServices@2019-06-01' = {
    name: '${storageAccountResource.name}/default'
    properties: {
        cors: {
            corsRules: [
            ]
        }
        deleteRetentionPolicy: {
            enabled: true
            days: 7
        }
    }
}


// --------------------------------------------------------------------------------
output name string = storageAccountResource.name
output id string = storageAccountResource.id
output blobStorageConnectionString string = 'DefaultEndpointsProtocol=https;AccountName=${storageAccountResource.name};AccountKey=${listKeys(storageAccountResource.id, '2019-06-01').keys[0].value};EndpointSuffix=core.windows.net'
