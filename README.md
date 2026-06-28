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

## Requirements

* **Terraform**: `>= 1.0` (Latest tested version is `1.9.0`)
* **AWS Provider**: `~> 4.0` (To retain support for S3 bucket objects and launch configurations)
* **GCP Provider**: `~> 4.0`
* **Template Provider**: `>= 2.1.2`

## What to Configure Before Deploying

Before deploying these modules, ensure the following infrastructure and settings are prepared:

### For AWS Bastion:
1. **AWS Credentials**: Configure your AWS CLI or set environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`).
2. **Target Network**: Prepare an existing VPC and at least one public subnet ID (`vpc_subnet_ids`), so the bastion can receive a public IP.
3. **S3 Bucket**: Pre-create an S3 bucket (`infrastructure_bucket`) where the module can read/write persistent SSH host keys.
4. **SSH Key**: Have an SSH public key content ready to associate with the default `ubuntu` user (`ssh_public_key_file`).
5. **(Optional) Route53 Zone**: If you wish to enable automatic A-record registration, provide the Hosted Zone ID (`route53_zone_id`).

### For GCP Bastion:
1. **GCP Project**: Configure access to your GCP project (`gcloud auth application-default login`).
2. **Target Network**: Ensure a VPC network (`network_name`) and public subnetwork (`subnetwork_name`) are configured.
3. **GCS Bucket**: Pre-create a Google Cloud Storage bucket (`infrastructure_bucket`) for persistent SSH host keys.
4. **SSH Key**: Provide the public key content (`ssh_public_key_file`) for metadata login.
5. **(Optional) Cloud DNS Zone**: Provide the Managed Zone name (`dns_zone_name`) to enable Dynamic DNS updates on boot.

---

## CI/CD Pipeline & Mock Deployments

This repository has a built-in CI/CD pipeline managed via **GitHub Actions** ([.github/workflows/terraform.yml](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/.github/workflows/terraform.yml)):

1. **Lint & Validate (CI)**: On every push and Pull Request, the pipeline runs code format check (`terraform fmt`) and code validation (`terraform validate`) using Terraform **1.9.0** for both AWS and GCP examples.
2. **Deploy (CD Mock)**: When changes are merged into the `master` branch and the validation step passes, the pipeline initiates a simulated deploy job (`deploy_mock`). This step mocks out the `terraform plan` and `terraform apply` stages, printing deployment step logs and mock output variables for demonstration.
