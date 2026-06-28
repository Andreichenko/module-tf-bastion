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
  description = "The time that the bastion should restart, when necessary, after an an unattended upgrade. This sets the option in /etc/apt/apt.conf.d/50unattended-upgrades"

  # By default the time zone is UTC.
  default = "22:30"
}

variable "unattended_upgrade_email_recipient" {
  description = "An email address where unattended upgrade errors should be emailed. This sets the option in /etc/apt/apt.conf.d/50unattended-upgrades"
}

variable "unattended_upgrade_additional_configs" {
  description = "Additional configuration lines to add to /etc/apt/apt.conf.d/50unattended-upgrades"
  default     = ""
}

variable "vpc_subnet_ids" {
  description = "A list of VPC subnet IDs where the Auto Scaling Group can launch the bastion instance."
  type        = list(string)
}

variable "ssh_public_key_file" {
  description = "The path or content of the SSH public key file to associate with the default user."
  type        = string
}

variable "log_retention" {
  description = "The number of days to retain log events in the CloudWatch Log Group."
  type        = number
  default     = 30
}

variable "ssh_cidr_blocks" {
  description = "A list of CIDRs allowed to SSH to the bastion."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "route53_zone_id" {
  description = "The Route53 Zone ID where the DNS record for the bastion will be created. If left blank, DNS registration is skipped."
  type        = string
  default     = ""
}

variable "remove_root_access" {
  description = "Whether to remove sudo access from the default ubuntu user. Set to 'true' to remove, or 'false' to retain."
  type        = string
  default     = "true"
}

variable "additional_user_data" {
  description = "Additional user data shell commands to run before users are created."
  type        = string
  default     = ""
}

variable "additional_user_data_end" {
  description = "Additional user data shell commands to run after users are created."
  type        = string
  default     = ""
}

variable "additional_users" {
  description = "List of maps describing additional users to create on the bastion. Keys: login, authorized_keys, shell, supplemental_groups, gecos."
  type        = list(any)
  default     = []
}

variable "additional_external_users" {
  description = "List of maps describing additional external users to create on the bastion via a separate script. Keys: login, authorized_keys, shell, supplemental_groups, gecos."
  type        = list(any)
  default     = []
}

variable "instance_type" {
  description = "The EC2 instance type to use for the bastion."
  type        = string
  default     = "t3.micro"
}

variable "encrypt_root_volume" {
  description = "Whether to encrypt the root block device of the bastion instance."
  type        = bool
  default     = true
}

variable "arn_prefix" {
  description = "The AWS ARN prefix (e.g. 'arn:aws' or 'arn:aws-us-gov' for GovCloud)."
  type        = string
  default     = "arn:aws"
}

variable "ami_owner_id" {
  description = "The owner ID of the AMI to use for the standard AWS regions (defaults to Canonical)."
  type        = string
  default     = "099720109477"
}

variable "ami_owner_id_govcloud" {
  description = "The owner ID of the AMI to use for the GovCloud regions (defaults to Canonical GovCloud)."
  type        = string
  default     = "965251226590"
}

variable "ami_filter_value" {
  description = "The filter value to search for the base Ubuntu AMI."
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"
}