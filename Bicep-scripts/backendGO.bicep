@description('Location for all resources.')
param location string = resourceGroup().location
param vnetname string = 'goauctionsVNet'
param subnetName string = 'goDevopsSubnet'
param storageAccountName string = 'storageAccount'
param dnsRecordName string ='backendhostname'
param dnszonename string='thednszonename.dk'

// --- Get a reference to our existing Virtual Network ---
resource VNET 'Microsoft.Network/virtualNetworks@2020-11-01' existing = {
  name: vnetname
  resource subnet 'subnets@2022-01-01' existing = {
    name: subnetName
  }
}

// --- Get a reference to the existing storage ---
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName
}

// --- Create the backend container group ---
@description('auktionsHusetBackendGroup')
resource auktionsHusetBackendGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'auktionsHusetBackendGroup'
  location: location
  properties: {
    sku: 'Standard'
    containers: [
      {
        name: 'mongodb'
        properties: {
          image: 'mongo:latest'
          command: [
            'mongod'
            '--dbpath=/data/auktionsdb'
            '--auth'
            '--bind_ip_all'
          ]
          ports: [
            {
              port: 27017
            }
          ]
          environmentVariables: []
          resources: {
            requests: {
              memoryInGB: json('1.0')
              cpu: json('0.5')
            }
          }
          volumeMounts: [
            {
              name: 'db'
              mountPath: '/data/auktionsdb/'
            }
          ]
        }
      }
      {
        name: 'rabbitmq'
        properties: {
          image: 'rabbitmq:management'
          command: ['tail', '-f', '/dev/null']
          ports: [
            {
              port: 15672
            }
            {
              port: 5672
            }
          ]
          environmentVariables: []
          resources: {
            requests: {
              memoryInGB: json('1.0')
              cpu: json('0.5')
            }
          }
          volumeMounts: [
            {
              name: 'msgqueue'
              mountPath: '/var/lib/rabbitmq'
            }
          ]
        }
      }
      {
        name: 'vault'
        properties: {
          image: 'hashicorp/vault:latest'
          command: ['vault', 'server', '-config=/vault/config/config.hcl']
          ports: [
            {
              port: 8201
            }
          ]
          environmentVariables: [
            {
              name: 'VAULT_TOKEN'
              value: 'abcdef12-3456-7890-abcd-ef1234567890'
            }
            {
              name: 'VAULT_ADDR'
              value: 'https://0.0.0.0:8201/'
            }
            {
              name: 'VAULT_LOCAL_CONFIG'
              value: '{"listener": [{"tcp":{"address": "0.0.0.0:8201", "tls_disable": "0", "tls_cert_file":"/data/cert.pem", "tls_key_file":"/data/key.pem"}}], "default_lease_ttl": "168h", "max_lease_ttl": "720h", "ui": true}'
            }
            {
              name: 'VAULT_DEV_ROOT_TOKEN_ID'
              value: '1a2b3c4d-5e6f-7g8h-9i0j-123456789abc'
            }
            {
              name: 'PATH'
              value: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
            }
            {
              name: 'NAME'
              value: 'vault'
            }
            {
              name: 'VERSION'
              value: ''
            }
          ]
          resources: {
            requests: {
              memoryInGB: json('1.0')
              cpu: json('0.5')
            }
          }
          volumeMounts: [
            {
              name: 'vault-config'
              mountPath: '/vault/config'
            }
          ]
        }
      }
    ]
    initContainers: []
    restartPolicy: 'Always'
    ipAddress: {
      ports: [
        {
          port: 27017
        }
        {
          port: 15672
        }
        {
          port: 5672
        }
        {
          port: 8201
        }
      ]
      ip: '10.0.1.4'
      type: 'Private'
    }
    osType: 'Linux'
    volumes: [
      {
        name: 'db'
        azureFile: {
          shareName: 'storagedata'
          storageAccountName: storageAccount.name
          storageAccountKey: storageAccount.listKeys().keys[0].value
        }
      }
      {
        name: 'msgqueue'
        azureFile: {
          shareName: 'storagequeue'
          storageAccountName: storageAccount.name
          storageAccountKey: storageAccount.listKeys().keys[0].value
        }
      }
      {
        name: 'vault-config'
        azureFile: {
          shareName: 'vaultconfig'
          storageAccountName: storageAccount.name
          storageAccountKey: storageAccount.listKeys().keys[0].value
        }
      }
    ]
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

// --- Get a reference to the existing DNS Zone ---
resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: dnszonename
}

// --- Create the DNS record for the backend container group ---
resource dnsRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: dnsRecordName
  parent: dnsZone
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: auktionsHusetBackendGroup.properties.ipAddress.ip
      }
    ]
  }
}

output containerIPAddressFqdn string = auktionsHusetBackendGroup.properties.ipAddress.ip 

