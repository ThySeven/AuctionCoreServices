@description('Location for all resources.')
param location string = resourceGroup().location

param vnetname string = 'theVNet'
param subnetName string = 'goservicesSubnet'
param dnsRecordName string ='serviceshostname'
param dnszonename string='thednszonename.dk'
param storageAccountName string='nostorage'

resource VNET 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: vnetname
  resource subnet 'subnets@2022-01-01' existing = {
    name: subnetName
  }
}

// --- Get a reference to the existing storage account ---
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName
}

// --- Create the DevOps container group ---
@description('auktionsHuset services Container Group')
resource auktionsHusetDevOpsGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {

  name: 'auktionsHusetservicesGroup'
  location: location

  properties: {
    sku: 'Standard'

    containers: [
      {
        name: 'invoice'
        properties: {
          image: 'thyseven/invoiceservice:dev'
          ports: [
            {
              port: 3005
            }
          ]
          environmentVariables: []
          resources: {
            requests: {
              memoryInGB: json('1.0')
              cpu: json('0.5')
            }
          }
        }
      }
      {
        name: 'user'
        properties: {
          image: 'thyseven/userservice:dev'
          ports: [
            {
              port: 3015
            }
          ]
          environmentVariables: []
          resources: {
            requests: {
              memoryInGB: json('1.0')
              cpu: json('0.5')
            }
          }
        }
      }
      {
        name: 'mail'
        properties: {
          image: 'thyseven/mailservice:dev'
          ports: [
            {
              port: 3010
            }
          ]
          environmentVariables: []
          resources: {
            requests: {
              memoryInGB: json('1.0')
              cpu: json('0.5')
            }
          }
        }
      }
      {
        name: 'bidding'
        properties: {
          image: 'thyseven/biddingservice:latest'
          ports: [
            {
              port: 3020
            }
          ]
          environmentVariables: []
          resources: {
            requests: {
              memoryInGB: json('1.0')
              cpu: json('0.5')
            }
          }
        }
      }
      {
        name: 'lot'
        properties: {
          image: 'thyseven/lotservice:dev'
          ports: [
            {
              port: 3025
            }
          ]
          environmentVariables: []
          resources: {
            requests: {
              memoryInGB: json('1.0')
              cpu: json('0.5')
            }
          }
        }
      }
    ]
    initContainers: []
    restartPolicy: 'Always'
    ipAddress: {
      ports: [
        {
          port: 3005
        }
        {
          port: 3010
        }
        {
          port: 3015
        }
        {
          port: 3020
        }
        {
          port: 3025
        }
      ]
      ip: '10.0.2.4'
      type: 'Private'
    }
    osType: 'Linux'
    subnetIds: [
      {
        id: VNET::subnet.id
      }
    ]
    dnsConfig: {
      nameServers: [
        '10.0.0.10'
        '10.0.0.11'
      ]
      searchDomains: dnszonename
    }
  }
}

// --- Get a reference to the existing DNS zone ---
resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: dnszonename
}

// --- Create the DNS record for the DevOps container group ---
resource dnsRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: dnsRecordName
  parent: dnsZone
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: auktionsHusetDevOpsGroup.properties.ipAddress.ip
      }
    ]
  }
}

output containerIPAddressFqdn string = auktionsHusetDevOpsGroup.properties.ipAddress.ip