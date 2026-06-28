# Terraform Azure Bastion Module

This module manages a Microsoft Azure bastion host running on an Ubuntu Virtual Machine Scale Set (VMSS) of size 1, its Network Security Group (NSG), Managed Identity (System Assigned), and Diagnostic Logs integration.

## Key Design Features

* **Self-Healing**: Runs inside a Virtual Machine Scale Set (VMSS) of size 1. If the instance fails, Azure automatically redeploys it.
* **Persistent Host Keys**: SSH host keys are stored in an Azure Blob Storage container. If the VM is recycled, the host keys are restored using Azure CLI and Managed Identity authentication, preventing SSH client warning messages.
* **Unattended Upgrades**: Automatically installs security patches and reboots during a configurable time window if needed.
* **Logging**: Azure Monitor Agent (or OMS Extension) is configured to automatically ship syslog and auth logs to a specified Log Analytics Workspace.
* **Dynamic Public IP & DNS**: Assigns a dynamic Public IP per VMSS instance with a configurable domain name label (e.g. `mybastion.eastus.cloudapp.azure.com`).
* **Access Control**: Sudo rights can be stripped from the default `ubuntu` user, and additional local/external users can be defined with their own SSH public keys.

## Example Usage

See a complete example in [examples/azure/main.tf](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/examples/azure/main.tf).

```hcl
module "azure_bastion" {
  source = "git::https://github.com/Andreichenko/module-tf-bastion.git//azure"

  bastion_name                       = "my-bastion"
  location                           = "East US"
  resource_group_name                = "my-resource-group"
  subnet_id                          = "/subscriptions/.../subnets/my-subnet"
  infrastructure_storage_account_id  = "/subscriptions/.../storageAccounts/mystorage"
  log_analytics_workspace_id         = "/subscriptions/.../workspaces/myworkspace"
  ssh_public_key_file                = "ssh-rsa AAAAB3..."
  unattended_upgrade_email_recipient = "admin@example.com"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bastion\_name | Prefix for all created Azure resources. | `string` | `"su-bastion"` | no |
| resource\_group\_name | Existing Resource Group name. | `string` | n/a | yes |
| location | Azure region. | `string` | n/a | yes |
| subnet\_id | Existing Subnet resource ID. | `string` | n/a | yes |
| infrastructure\_storage\_account\_id | Existing Storage Account resource ID for keys backup. | `string` | n/a | yes |
| infrastructure\_storage\_container\_name | Blob storage container name. | `string` | `"bastion"` | no |
| unattended\_upgrade\_reboot\_time | Time for automatic reboot if needed (UTC). | `string` | `"22:30"` | no |
| unattended\_upgrade\_email\_recipient | Email address for unattended upgrade error alerts. | `string` | n/a | yes |
| unattended\_upgrade\_additional\_configs | Extra configurations appended to unattended-upgrades config file. | `string` | `""` | no |
| remove\_root\_access | Strip sudo access from the default `ubuntu` user (`"true"` or `"false"`). | `string` | `"true"` | no |
| additional\_users | List of maps describing additional local users to create. | `list(any)` | `[]` | no |
| additional\_external\_users | List of maps describing additional external users to sync via Blob Storage. | `list(any)` | `[]` | no |
| additional\_setup\_script | Custom shell commands executed *before* creating users. | `string` | `""` | no |
| sku | VMSS instance size SKU. | `string` | `"Standard_B1s"` | no |
| ssh\_public\_key\_file | SSH public key content to assign to the default `ubuntu` user. | `string` | n/a | yes |
| ssh\_cidr\_blocks | List of CIDR blocks allowed to connect to SSH (22). | `list(string)` | `["*"]` | no |
| image\_publisher | VM Image Publisher. | `string` | `"Canonical"` | no |
| image\_offer | VM Image Offer. | `string` | `"0001-com-ubuntu-server-jammy"` | no |
| image\_sku | VM Image SKU. | `string` | `"22_04-lts-gen2"` | no |
| image\_version | VM Image Version. | `string` | `"latest"` | no |
| log\_analytics\_workspace\_id | Resource ID of the existing Log Analytics Workspace to forward logs. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| nsg\_id | The ID of the Network Security Group associated with the bastion. |
| vmss\_id | The ID of the Linux Virtual Machine Scale Set. |
| vmss\_identity\_principal\_id | The Principal ID of the Managed Identity for the VMSS. |
