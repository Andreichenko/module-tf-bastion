variable "bastion_name" {
  description = "The name of the bastion compute instance, DNS hostname, IAM service account, and the prefix for resources such as the firewall rule, instance template, and instance group."
  default     = "su-bastion"
}

variable "region" {
  description = "The region where the bastion should be provisioned. This is a required input for the google_compute_region_instance_group_manager Terraform resource, and is not inherited from the provider."
}