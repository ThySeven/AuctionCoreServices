@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of virtual network')
var virtualNetworkName = 'goauctionsVNet'

@description('Name of public ip address')
var publicIPAddressName = 'goauctions-public_ip'

@description('Name of the DNS zone')
var dnszonename = 'auktionshuset.dk'

@description('Public Domain name used when accessing gateway from internet')
var publicDomainName = 'auktionshusetgo'

// --- Call Bicep submodules ------------------------------

module network 'networkGO.bicep' = {
  name: 'networkModule'
  params: {
    location: location
    virtualNetworkName: virtualNetworkName
    publicIPAddressName: publicIPAddressName
    publicDomainName: publicDomainName
    dnszonename: dnszonename
  }  
}

module storage 'storageGO.bicep' = {
  name: 'storageModule'
  params: {
    location: location
    sharePrefix: 'storage'
    shareNames: [
      'config'
      'data'
      'images'
      'queue'
      'grafana'
    ]
  }  
}

module devops 'devopsGO.bicep' = {
  name: 'devopsModule'
  params: {
    location: location
    vnetname: virtualNetworkName
    subnetName: 'goDevopsSubnet'
    dnsRecordName: 'DEVOPS'
    dnszonename: dnszonename
    storageAccountName: storage.outputs.storageAcountName
  }
}

module backend 'backendGO.bicep' = {
  name: 'backendModule'
  params: {
    location: location
    vnetname: virtualNetworkName
    subnetName: 'goBackendSubnet'
    dnsRecordName: 'BACKEND'
    dnszonename: dnszonename
    storageAccountName: storage.outputs.storageAcountName
  }
}

// --- Create the Azure Function App ---
resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: 'goauctionsFunctionApp'
  location: location
  properties: {
    serverFarmId: '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Web/serverfarms/{appServicePlanName}'
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'AzureWebJobsStorage'
          value: storage.outputs.storageAcountName.connectionString
        }
      ]
    }
  }
  dependsOn: [
    network
    devops
    backend
  ]
}

output functionAppId string = functionApp.id
