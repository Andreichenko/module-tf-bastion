# Terraform AWS Bastion Module

This module manages an Amazon Web Services (AWS) bastion EC2 instance, its Auto Scaling Group (size 1), Instance Profile/Role, CloudWatch Log Group, Security Group, and SSH Key Pair. The Auto Scaling Group will recreate the bastion if there is an issue with the EC2 instance or the availability zone where it is running.

## Key Design Features

* **Self-Healing**: Runs inside an Auto Scaling Group of size 1. If the instance fails, it is automatically recreated.
* **Persistent Host Keys**: SSH host keys are stored in an S3 bucket. If the instance is recycled, the host keys are restored to avoid "Remote Host Identification Changed" warnings.
* **Unattended Upgrades**: Automatically installs security patches and reboots during a configurable time window if needed (e.g. after a kernel update).
* **Logging**: CloudWatch Log Agent automatically ships `/var/log/syslog` and `/var/log/auth.log` to a dedicated CloudWatch Log Group.
* **Automatic DNS**: Integrates with Route53 to register the public IP on boot using `cli53`.
* **Access Control**: Sudo rights can be stripped from the default `ubuntu` user, and additional local/external users can be defined with their own SSH public keys.

## Example Usage

See a complete example in [examples/aws/main.tf](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/examples/aws/main.tf).

```hcl
module "aws_bastion" {
  source = "git::https://github.com/Andreichenko/module-tf-bastion.git//aws"

  bastion_name           = "my-bastion"
  infrastructure_bucket  = "my-bastion-infra-bucket"
  vpc_subnet_ids         = ["subnet-12345678"]
  ssh_public_key_file    = "ssh-rsa AAAAB3..."
  
  unattended_upgrade_email_recipient = "admin@example.com"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bastion\_name | Prefix for all created AWS resources. | `string` | `"su-bastion"` | no |
| infrastructure\_bucket | S3 bucket to persist SSH host keys and additional external user scripts. | `string` | n/a | yes |
| infrastructure\_bucket\_bastion\_key | Sub-directory path in the S3 bucket. | `string` | `"bastion"` | no |
| unattended\_upgrade\_reboot\_time | Time for automatic reboot if needed (UTC). | `string` | `"22:30"` | no |
| unattended\_upgrade\_email\_recipient | Email address for unattended upgrade error alerts. | `string` | n/a | yes |
| unattended\_upgrade\_additional\_configs | Extra configurations appended to unattended-upgrades config file. | `string` | `""` | no |
| vpc\_subnet\_ids | List of subnet IDs where the Auto Scaling Group can launch the bastion. | `list(string)` | n/a | yes |
| ssh\_public\_key\_file | SSH public key content to assign to the default `ubuntu` user. | `string` | n/a | yes |
| log\_retention | CloudWatch Log Group retention in days. | `number` | `30` | no |
| route53\_zone\_id | Route53 Zone ID to register the bastion domain name. If blank, DNS setup is skipped. | `string` | `""` | no |
| remove\_root\_access | Strip sudo access from the default `ubuntu` user (`"true"` or `"false"`). | `string` | `"true"` | no |
| additional\_user\_data | Custom shell commands executed *before* creating users. | `string` | `""` | no |
| additional\_user\_data\_end | Custom shell commands executed *after* creating users. | `string` | `""` | no |
| additional\_users | List of maps describing additional local users to create. | `list(any)` | `[]` | no |
| additional\_external\_users | List of maps describing additional external users to sync via S3. | `list(any)` | `[]` | no |
| instance\_type | EC2 Instance Type. | `string` | `"t3.micro"` | no |
| encrypt\_root\_volume | Enable root block device encryption. | `bool` | `true` | no |
| arn\_prefix | AWS Partition prefix (e.g. `arn:aws` or `arn:aws-us-gov`). | `string` | `"arn:aws"` | no |
| ami\_owner\_id | Owner ID of the Ubuntu AMI to search for standard regions. | `string` | `"099720109477"` (Canonical) | no |
| ami\_owner\_id\_govcloud | Owner ID of the Ubuntu AMI to search for GovCloud regions. | `string` | `"965251226590"` | no |
| ami\_filter\_value | Filter string to find the base Ubuntu AMI. | `string` | `"ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"` | no |

## Outputs

| Name | Description |
|------|-------------|
| security\_group\_id | The ID of the Security Group associated with the bastion. |