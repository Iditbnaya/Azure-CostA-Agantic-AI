@description('Name of the Function App')
param functionAppName string = 'func-costanalysis-${environment}-001'

@description('Name of the App Service Plan')
param hostingPlanName string = 'plan-costanalysis-${environment}'

@description('Name of the Storage Account')
param storageAccountName string = 'sacost${environment}${uniqueString(resourceGroup().id)}'

@description('Environment (dev, test, prod)')
param environment string = 'prod'

@description('Location for all resources')
param location string = resourceGroup().location

@description('Function App runtime')
param runtime string = 'python'

@description('Function App runtime version')
param runtimeVersion string = '3.11'

@description('App Service Plan SKU')
param skuName string = 'Y1'

@description('Resource tags')
param tags object = {
  Environment: toUpper(environment)
  Application: 'Azure Cost Management'
  Project: 'Cost Optimization'
  Owner: 'FinOps Team'
  CostCenter: 'IT-Operations'
}

// Storage Account for Function App
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-04-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
    }
  }
}

// App Service Plan for Linux Consumption
resource hostingPlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: hostingPlanName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

// Azure Function App
resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  tags: tags
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    reserved: true
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      linuxFxVersion: '${toUpper(runtime)}|${runtimeVersion}'
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${az.environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: runtime
        }
        {
          name: 'WEBSITE_PYTHON_DEFAULT_VERSION'
          value: runtimeVersion
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
        {
          name: 'ENABLE_ORYX_BUILD'
          value: 'true'
        }
      ]
    }
  }
}

// Outputs
@description('Function App Name')
output functionAppName string = functionApp.name

@description('Function App URL')
output functionAppUrl string = 'https://${functionApp.properties.defaultHostName}'

@description('Function App Principal ID')
output functionAppPrincipalId string = functionApp.identity.principalId

@description('Storage Account Name')
output storageAccountName string = storageAccount.name
