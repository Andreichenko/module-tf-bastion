# Terraform-bastion modules for GCP and AWS
These Terraform modules manage an Amazon Web Services (AWS) or Google Cloud Platform (GCP) bastion and its Auto Scaling Group, Identity and Access Management (IAM) resources, remote logging, SSH users and firewall access. The Auto Scaling Group will recreate the bastion if there is an issue with the compute instance or the AWS availability zone where it is running.

## Key Design Features

The bastion should be created in any availability zone used by the AWS VPC or GCP network, and should heal in the event of an availability zone outage. SSH logs should additionally be stored outside the bastion, for good auditing practices and to retain logs if the bastion instance is recreated. The bastion should automatically update operating system packages and reboot as needed when a new kernel is installed.
## Requirements

No requirements.

## Providers

No provider.

## Inputs

No input.

## Outputs

No output.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >=2.30.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >=2.30.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bastion\_name | The name of the bastion EC2 instance, DNS hostname, CloudWatch Log Group, and the name prefix for other related resources. | `string` | `"su-bastion"` | no |
| infrastructure\_bucket | An S3 bucket to store data that should persist on the bastion when it is recycled by the Auto Scaling Group, such as SSH host keys. This can be set in the environment via `TF_VAR_infrastructure_bucket` | `any` | n/a | yes |
| infrastructure\_bucket\_bastion\_key | The key; sub-directory in $infrastructure\_bucket where the bastion will be allowed to read and write. Do not specify a trailing slash. This allows sharing an S3 bucket among multiple invocations of this module. | `string` | `"bastion"` | no |
| unattended\_upgrade\_additional\_configs | Additional configuration lines to add to /etc/apt/apt.conf.d/50unattended-upgrades | `string` | `""` | no |
| unattended\_upgrade\_email\_recipient | An email address where unattended upgrade errors should be emailed. THis sets the option in /etc/apt/apt.conf.d/50unattended-upgrades | `any` | n/a | yes |
| unattended\_upgrade\_reboot\_time | The time that the bastion should reboot, when necessary, after an an unattended upgrade. This sets the option in /etc/apt/apt.conf.d/50unattended-upgrades | `string` | `"22:30"` | no |

## Outputs

No output.

