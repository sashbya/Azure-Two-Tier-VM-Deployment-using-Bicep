@description('Deployment location')
@allowed(['japaneast', 'eastus', 'westeurope', 'northeurope'])
param location string = 'japaneast'

@description('Name of the vnet')
param vnetName string = 'demo-vnet'

@description('Name of the web subnet')
param webSubnetName string = 'web-subnet'

@description('Name of the db-subnet')
param dbSubnetName string = 'db-subnet'


@description('Name of the NSG')
param nsgName string = 'vm-nsg'

// Create NSG
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-RDP'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: webSubnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
      {
        name: dbSubnetName
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}
@description('Name of the first VM (web)')
param webVmName string = 'web-vm'

@description('Name of the second VM (database)')
param dbVmName string = 'db-vm'

@description('VM size for both VMs')
param vmSize string = 'Standard_B1s'

@description('Admin username for the VMs')
param adminUsername string = 'azureuser'

@secure()
@description('Admin password for the VMs')
param adminPassword string

// Web VM
resource webNic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: '${webVmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource webVm 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: webVmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: webVmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: webNic.id
        }
      ]
    }
  }
}

// DB VM setup is almost identical
resource dbNic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: '${dbVmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[1].id
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource dbVm 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: dbVmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: dbVmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: dbNic.id
        }
      ]
    }
  }
}


