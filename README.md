# Terraform Bastion Modules for GCP and AWS

This repository contains reusable Terraform modules to manage a secure, resilient, and self-healing bastion host on either Amazon Web Services (AWS) or Google Cloud Platform (GCP).

## Key Design Features

* **Self-Healing (Auto Scaling)**: The bastion is deployed inside a Managed Instance Group (GCP) or Auto Scaling Group (AWS) of size 1. If the instance fails or its Availability Zone experiences an outage, a new bastion is immediately provisioned in another zone.
* **Persistent Host Keys**: SSH host keys are stored externally in an S3 (AWS) or GCS (GCP) bucket. When the instance is recycled, the host keys are synchronized back, ensuring that SSH clients do not encounter "Remote Host Identification Changed" warnings.
* **Unattended Security Upgrades**: The operating system (Ubuntu) is automatically configured to install security patches and perform a reboot at a scheduled quiet hour if a kernel update requires it.
* **Central Logging**: The instance ships critical authentication logs (`/var/log/auth.log` and `/var/log/syslog`) to external services (AWS CloudWatch Logs or Google Cloud Logging) so that access logs are retained even after the bastion is recycled.
* **Dynamic DNS Registration**: Upon booting, the bastion automatically queries its new public IP and updates an A record in a managed Route53 (AWS) or Cloud DNS (GCP) zone.
* **User Management**: You can disable root/sudo permissions for the default `ubuntu` user and define a list of additional local or external users with their own SSH public keys.

## Repository Structure

* **[aws/](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/aws/)**: Terraform module for AWS Bastion.
* **[gcp/](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/gcp/)**: Terraform module for GCP Bastion.
* **[examples/](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/examples/)**: Example configurations demonstrating how to invoke the modules.

## Getting Started

Refer to the respective README files for usage details, variables, and outputs:
* For AWS, see **[AWS Bastion README](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/aws/README.md)**.
* For GCP, see **[GCP Bastion README](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/gcp/README.md)**.

Complete, ready-to-use examples can be found under:
* **[examples/aws/main.tf](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/examples/aws/main.tf)**
* **[examples/gcp/main.tf](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/examples/gcp/main.tf)**
