variable "bastion_name" {
  description = "The name of the bastion compute instance, DNS hostname, IAM service account, and the prefix for resources such as the firewall rule, instance template, and instance group."
  default     = "su-bastion"
}

variable "region" {
  description = "The region where the bastion should be provisioned. This is a required input for the google_compute_region_instance_group_manager Terraform resource, and is not inherited from the provider."
}

variable "availability_zones" {
  description = "The availability zones within $region where the Auto Scaling Group can place the bastion."
  type        = list
}

variable "infrastructure_bucket" {
  description = "An GCS bucket to store data that should persist on the bastion when it is recycled by the Auto Scaling Group, such as SSH host keys. This can be set in the environment via `TF_VAR_infrastructure_bucket`"
}

variable "infrastructure_bucket_bastion_key" {
  description = "The key; sub-directory in $infrastructure_bucket where the bastion will be allowed to read and write. Do not specify a trailing slash. This allows sharing a GCS bucket among multiple invocations of this module."
  default     = "bastion"
}