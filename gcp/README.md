# Terraform GCP Bastion Module

This module manages a Google Cloud Platform (GCP) bastion compute instance, its regional Managed Instance Group (size 1), Service Account, SSH Firewall Rule, Cloud DNS record, and GCS bucket access. The Managed Instance Group will recreate the bastion if there is an issue with the compute instance or the availability zone where it is running.

## Key Design Features

* **Self-Healing**: Runs inside a regional Managed Instance Group of size 1. If the instance fails or the zone goes down, it is automatically recreated.
* **Persistent Host Keys**: SSH host keys are stored in a Google Cloud Storage (GCS) bucket. Если инстанс пересоздается, ключи восстанавливаются, предотвращая предупреждение "Remote Host Identification Changed".
* **Unattended Upgrades**: Automatically installs security patches and reboots during a configurable time window if needed.
* **Logging**: Google Cloud Logging Agent (fluentd) automatically ships logs (including `/var/log/auth.log` and `/var/log/syslog`) to GCP Cloud Logging.
* **Automatic DNS**: Automatically registers the dynamic public IP of the bastion in Google Cloud DNS on boot.
* **Access Control**: Sudo rights can be stripped from the default `ubuntu` user, and additional local/external users can be defined with their own SSH public keys.

## Example Usage

See a complete example in [examples/gcp/main.tf](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/examples/gcp/main.tf).

```hcl
module "gcp_bastion" {
  source = "git::https://github.com/Andreichenko/module-tf-bastion.git//gcp"

  bastion_name           = "my-bastion"
  region                 = "us-central1"
  availability_zones     = ["us-central1-a", "us-central1-b"]
  infrastructure_bucket  = "my-bastion-infra-bucket"
  dns_zone_name          = "my-managed-dns-zone"
  network_name           = "my-vpc-network"
  subnetwork_name        = "my-public-subnet"
  ssh_public_key_file    = "ssh-rsa AAAAB3..."
  
  unattended_upgrade_email_recipient = "admin@example.com"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bastion\_name | Prefix for all created GCP resources. | `string` | `"su-bastion"` | no |
| region | The GCP region where resources should be provisioned. | `string` | n/a | yes |
| availability\_zones | List of zones within the region to spread the Managed Instance Group. | `list` | n/a | yes |
| infrastructure\_bucket | GCS bucket to persist SSH host keys and additional external user scripts. | `string` | n/a | yes |
| infrastructure\_bucket\_bastion\_key | Sub-directory path in the GCS bucket. | `string` | `"bastion"` | no |
| unattended\_upgrade\_reboot\_time | Time for automatic reboot if needed (UTC). | `string` | `"22:30"` | no |
| unattended\_upgrade\_email\_recipient | Email address for unattended upgrade error alerts. | `string` | n/a | yes |
| unattended\_upgrade\_additional\_configs | Extra configurations appended to unattended-upgrades config file. | `string` | `""` | no |
| remove\_root\_access | Strip sudo access from the default `ubuntu` user (`"true"` or `"false"`). | `string` | `"true"` | no |
| additional\_users | List of maps describing additional local users to create. | `list` | `[]` | no |
| additional\_external\_users | List of maps describing additional external users to sync via GCS. | `list` | `[]` | no |
| additional\_setup\_script | Custom shell commands executed *before* creating users. | `string` | `""` | no |
| machine\_type | Compute Instance machine type. | `string` | `"n1-standard-1"` | no |
| dns\_zone\_name | The managed Google Cloud DNS zone name where the bastion record will be added. | `string` | n/a | yes |
| network\_name | VPC network name where the firewall rule will be created. | `string` | n/a | yes |
| subnetwork\_name | Subnet name where the bastion instance will run. | `string` | n/a | yes |
| ssh\_public\_key\_file | SSH public key content to assign to the default `ubuntu` user. | `string` | n/a | yes |
| ssh\_cidr\_blocks | List of CIDR blocks allowed to connect to SSH (22). | `list(string)` | `["0.0.0.0/0"]` | no |
| image\_family | Compute image family to use. | `string` | `"ubuntu-1804-lts"` | no |
| image\_project | Compute image project owner. | `string` | `"ubuntu-os-cloud"` | no |

## Outputs

No outputs.