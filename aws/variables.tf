variable "bastion_name" {
  description = "The name of the bastion EC2 instance, DNS hostname, CloudWatch Log Group, and the name prefix for other related resources."
  default     = "su-bastion"
}

variable "infrastructure_bucket" {
  description = "An S3 bucket to store data that should persist on the bastion when it is recycled by the Auto Scaling Group, such as SSH host keys. This can be set in the environment via `TF_VAR_infrastructure_bucket`"
}
