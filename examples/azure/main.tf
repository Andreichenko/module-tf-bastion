terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.1.2"
    }
  }
}

provider "azurerm" {
  features {}
}

# Example Resource Group
resource "azurerm_resource_group" "main" {
  name     = "bastion-rg"
  location = "East US"
}

# Example Virtual Network & Subnet
resource "azurerm_virtual_network" "main" {
  name                = "bastion-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "public" {
  name                 = "bastion-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Example Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = "bastion-law"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Example Storage Account & Container
resource "azurerm_storage_account" "infra" {
  name                     = "bastioninfrasaunique"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "infra" {
  name                  = "bastion"
  storage_account_name  = azurerm_storage_account.infra.name
  container_access_type = "private"
}

module "azure_bastion" {
  source = "../../azure"

  bastion_name                       = "production-bastion"
  location                           = azurerm_resource_group.main.location
  resource_group_name                = azurerm_resource_group.main.name
  subnet_id                          = azurerm_subnet.public.id
  infrastructure_storage_account_id  = azurerm_storage_account.infra.id
  infrastructure_storage_container_name = azurerm_storage_container.infra.name
  log_analytics_workspace_id         = azurerm_log_analytics_workspace.main.id
  ssh_public_key_file                = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ..." # Replace with actual public key
  
  unattended_upgrade_email_recipient = "admin@example.com"
  unattended_upgrade_reboot_time     = "03:00"

  remove_root_access = "true"

  additional_users = [
    {
      login           = "alice"
      gecos           = "Alice Developer"
      shell           = "/bin/bash"
      authorized_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQAB..."
    },
    {
      login           = "bob"
      gecos           = "Bob DevOps"
      shell           = "/bin/zsh"
      authorized_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQAB..."
    }
  ]

  additional_external_users = [
    {
      login           = "external-audit"
      gecos           = "External Auditor"
      shell           = "/bin/bash"
      authorized_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQAB..."
    }
  ]
}

output "bastion_nsg_id" {
  value = module.azure_bastion.nsg_id
}
