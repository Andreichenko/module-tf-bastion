variable "bastion_name" {
  description = "The name of the bastion VMSS, public IP, NSG, and other related resources."
  type        = string
  default     = "su-bastion"
}

variable "resource_group_name" {
  description = "The name of the existing resource group where the bastion resources will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the existing subnet where the bastion VMSS will be connected."
  type        = string
}

variable "infrastructure_storage_account_id" {
  description = "The ID of the existing Azure Storage Account to store SSH host keys."
  type        = string
}

variable "infrastructure_storage_container_name" {
  description = "The container name within the Storage Account to store the keys."
  type        = string
  default     = "bastion"
}

variable "unattended_upgrade_reboot_time" {
  description = "The time that the bastion should reboot, when necessary, after an unattended upgrade (UTC)."
  type        = string
  default     = "22:30"
}

variable "unattended_upgrade_email_recipient" {
  description = "An email address where unattended upgrade errors should be emailed."
  type        = string
}

variable "unattended_upgrade_additional_configs" {
  description = "Additional configuration lines to add to /etc/apt/apt.conf.d/50unattended-upgrades"
  type        = string
  default     = ""
}

variable "remove_root_access" {
  description = "Whether to remove sudo access from the default ubuntu user. Set to 'true' to remove, or 'false' to retain."
  type        = string
  default     = "true"
}

variable "additional_users" {
  description = "List of maps describing additional local users to create on the bastion."
  type        = list(any)
  default     = []
}

variable "additional_external_users" {
  description = "List of maps describing additional external users to sync via Blob Storage."
  type        = list(any)
  default     = []
}

variable "additional_setup_script" {
  description = "Content to be appended to the setup script, which is run the first time the bastion VMSS boots."
  type        = string
  default     = ""
}

variable "sku" {
  description = "The SKU / size of the virtual machines in the VMSS."
  type        = string
  default     = "Standard_B1s"
}

variable "ssh_public_key_file" {
  description = "The content of the SSH public key for the default ubuntu user."
  type        = string
}

variable "ssh_cidr_blocks" {
  description = "A list of CIDRs allowed to SSH to the bastion."
  type        = list(string)
  default     = ["*"]
}

variable "image_publisher" {
  description = "The publisher of the image."
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "The offer name of the image."
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "The SKU of the image."
  type        = string
  default     = "22_04-lts-gen2"
}

variable "image_version" {
  description = "The version of the image."
  type        = string
  default     = "latest"
}

variable "log_analytics_workspace_id" {
  description = "The resource ID of the existing Log Analytics Workspace to send SSH logs to."
  type        = string
}
