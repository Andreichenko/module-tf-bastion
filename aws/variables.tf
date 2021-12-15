variable "bastion_name" {
  description = "The name of the bastion EC2 instance, DNS hostname, CloudWatch Log Group, and the name prefix for other related resources."
  default     = "su-bastion"
}

variable "infrastructure_bucket" {
  description = "An S3 bucket to store data that should persist on the bastion when it is recycled by the Auto Scaling Group, such as SSH host keys. This can be set in the environment via `TF_VAR_infrastructure_bucket`"
}

variable "infrastructure_bucket_bastion_key" {
  description = "The key; sub-directory in $infrastructure_bucket where the bastion will be allowed to read and write. Do not specify a trailing slash. This allows sharing an S3 bucket among multiple invocations of this module."
  default     = "bastion"
}

variable "unattended_upgrade_reboot_time" {
  description = "The time that the bastion should reboot, when necessary, after an an unattended upgrade. This sets the option in /etc/apt/apt.conf.d/50unattended-upgrades"

  # By default the time zone is UTC.
  default = "22:30"
}

variable "unattended_upgrade_email_recipient" {
  description = "An email address where unattended upgrade errors should be emailed. THis sets the option in /etc/apt/apt.conf.d/50unattended-upgrades"
}

variable "unattended_upgrade_additional_configs" {
  description = "Additional configuration lines to add to /etc/apt/apt.conf.d/50unattended-upgrades"
  default     = ""
}