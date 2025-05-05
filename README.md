
# Azure Two-Tier VM Deployment (Bicep)

This project provisions a simple two-tier architecture in Azure using Bicep. It creates:
- A Virtual Network (`demo-vnet`) with two subnets (`web-subnet` and `db-subnet`)
- A **Web Tier** with a VM in the `web subnet` for application/frontend logic.
- A **Database Tier** with a VM in the `db-subnet` for backend/database functions.
- A Network Security Group (NSG) allowing RDP traffic
- NICs attached to each VM and associated with their respective subnets

The project was completed using **VSCode** and the Azure Portal for verification.
Basic requirements: Azure Subscription, Azure CLI and Bicep (extensions in VSCode)

## Deploy the template

The template file `main.bicep` attached was then deployed using **PowerShell**.
```Powershell
az login
az group create --name test-rg --location japaneast
az deployment group create --resource-group test-rg --template-file main.bicep
```
*Note: You will be prompted to enter a secure password, ensure this meets Azure's complexity requirements. It must be between 
8 and 64 characters and meet 3 out of 4 of lowercase, uppercase, numbers, or symbols.*
![Deployment screenshot](https://github.com/sashbya/Azure-Two-Tier-VM-Deployment-using-Bicep/blob/main/main.bicep)

## Parameters

| Parameter         | Description                          | Default         |
|------------------|--------------------------------------|-----------------|
| `location`        | Azure region for deployment          | `japaneast`     |
| `vnetName`        | Name of the Virtual Network           | `demo-vnet`     |
| `webSubnetName`   | Name of the Web Subnet                | `web-subnet`    |
| `dbSubnetName`    | Name of the DB Subnet                 | `db-subnet`     |
| `nsgName`         | Name of the Network Security Group    | `vm-nsg`        |
| `webVmName`       | Name of the Web VM                    | `web-vm`        |
| `dbVmName`        | Name of the DB VM                     | `db-vm`         |
| `vmSize`          | Azure VM size                         | `Standard_B1s`  |
| `adminUsername`   | VM admin username                     | `azureuser`     |
| `adminPassword`   | VM admin password (secure string)     | *(required)*    |

## Notes

- This deployment opens port `3389`(RDP) to the internet via the NSG. Restrict this in production by modifying the NSG rules.
- VMs do not include public IPs by default. To expose the VMs publicly, attach a Public IP or configure Azure Bastion.
- This template can be customized by adding storage accounts, diagnostics or even additional NSG rules.

## Clean Up

Best practice after this test deployment is to delete resources no longer in use. This will ensure no costs are inadvertently incurred.
```Powershell
az group delete --name test-rg --yes --no-wait
```
*The `no-wait` command allows you to execute other commands while the resources are being deleted.*
