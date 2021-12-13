# Terraform-bastion modules for GCP and AWS
These Terraform modules manage an Amazon Web Services (AWS) or Google Cloud Platform (GCP) bastion and its Auto Scaling Group, Identity and Access Management (IAM) resources, remote logging, SSH users and firewall access. The Auto Scaling Group will recreate the bastion if there is an issue with the compute instance or the AWS availability zone where it is running.

## Key Design Features

The bastion should be created in any availability zone used by the AWS VPC or GCP network, and should heal in the event of an availability zone outage. SSH logs should additionally be stored outside the bastion, for good auditing practices and to retain logs if the bastion instance is recreated. The bastion should automatically update operating system packages and reboot as needed when a new kernel is installed.
