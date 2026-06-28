data "template_file" "bastion_setup_script" {
  template = file("${path.module}/bastion-startup-script.tmpl")

  vars = {
    bastion_name                          = var.bastion_name
    infrastructure_storage_account_name   = data.azurerm_storage_account.infra.name
    infrastructure_storage_container_name = var.infrastructure_storage_container_name
    unattended_upgrade_reboot_time        = var.unattended_upgrade_reboot_time
    unattended_upgrade_email_recipient    = var.unattended_upgrade_email_recipient
    unattended_upgrade_additional_configs = var.unattended_upgrade_additional_configs
    remove_root_access                    = var.remove_root_access
    additional_setup_script               = var.additional_setup_script
    additional_user_templates             = join("\n", data.template_file.additional_user.*.rendered)
    additional_external_users_script_md5  = local.additional_external_users_script_md5
  }
}

resource "azurerm_network_security_group" "bastion" {
  name                = "${var.bastion_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.ssh_cidr_blocks
    destination_address_prefix = "*"
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "bastion" {
  name                = var.bastion_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  instances           = 1
  admin_username      = "ubuntu"

  admin_ssh_key {
    username   = "ubuntu"
    public_key = var.ssh_public_key_file
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name                      = "${var.bastion_name}-nic"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.bastion.id

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id

      public_ip_address {
        name              = "${var.bastion_name}-pip"
        domain_name_label = lower(var.bastion_name)
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  custom_data = base64encode(data.template_file.bastion_setup_script.rendered)

  lifecycle {
    ignore_changes = [instances]
  }
}

# Grant Storage Blob Data Contributor to VMSS Identity on the Storage Account
resource "azurerm_role_assignment" "storage_access" {
  scope                = var.infrastructure_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_virtual_machine_scale_set.bastion.identity[0].principal_id
}

# Attach Log Analytics agent extension to forward syslog & auth.log
resource "azurerm_virtual_machine_scale_set_extension" "omsagent" {
  name                         = "OmsAgentForLinux"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.bastion.id
  publisher                    = "Microsoft.EnterpriseCloud.Monitoring"
  type                         = "OmsAgentForLinux"
  type_handler_version         = "1.13"

  settings = <<SETTINGS
    {
      "workspaceId": "${var.log_analytics_workspace_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "workspaceKey": "${data.azurerm_log_analytics_workspace.selected.primary_shared_key}"
    }
  PROTECTED_SETTINGS
}

data "azurerm_log_analytics_workspace" "selected" {
  name                = element(split("/", var.log_analytics_workspace_id), length(split("/", var.log_analytics_workspace_id)) - 1)
  resource_group_name = element(split("/", var.log_analytics_workspace_id), 4)
}
