# Terraform Bastion Modules for GCP, AWS and Azure

![Terraform Version](https://img.shields.io/badge/Terraform-%3E%3D%201.0-844FBA?logo=terraform)
![AWS Provider](https://img.shields.io/badge/AWS-%7E%3E%204.0-FF9900?logo=amazon-aws)
![GCP Provider](https://img.shields.io/badge/GCP-%7E%3E%204.0-4285F4?logo=google-cloud)
![Azure Provider](https://img.shields.io/badge/Azure-%7E%3E%203.0-0089D6?logo=microsoft-azure)
![CI/CD Pipeline](https://img.shields.io/github/actions/workflow/status/Andreichenko/module-tf-bastion/terraform.yml?branch=master&label=CI%2FCD)

This repository contains reusable Terraform modules to manage a secure, resilient, and self-healing bastion host on Amazon Web Services (AWS), Google Cloud Platform (GCP), or Microsoft Azure.

---

## 📐 Architecture Diagram

Below is the conceptual architecture of how the Bastion host manages secure external access to your private infrastructure:

```mermaid
graph TD
    Client["💻 Client (SSH)"] -->|1. SSH:22 (Allowed CIDRs Only)| NSG["🛡️ Firewall / SG / NSG"]
    NSG -->|Allows access| Bastion["🚀 Bastion Host (Public Subnet)"]
    
    subgraph VPC_VNet ["🌐 VPC / VNet (Cloud Provider)"]
        Bastion
        
        subgraph Private_Subnet ["🔒 Private Subnet"]
            AppVM["🖥️ Internal App Servers (No Public IP)"]
            DB["🗄️ Private Databases (RDS/Cloud SQL/No Public IP)"]
        end
        
        subgraph Key_Storage ["📦 External Storage"]
            Keys["🔑 SSH Host Keys Storage (S3 / GCS / Azure Blob)"]
        end
        
        subgraph Logging ["📊 Logs Monitoring"]
            LogsService["📈 CloudWatch / Cloud Logging / Log Analytics"]
        end
    end
    
    Bastion <-->|2. Sync SSH Host Keys| Keys
    Bastion -->|3. Ship auth.log & syslog| LogsService
    Bastion -->|4. Access via SSH Tunneling| AppVM
    Bastion -->|4. Access via Port Forwarding| DB
```

---

## Key Design Features

* **Self-Healing (Auto Scaling)**: The bastion is deployed inside a Managed Instance Group (GCP), Auto Scaling Group (AWS), or Virtual Machine Scale Set (Azure) of size 1. If the instance fails or its Availability Zone experiences an outage, a new bastion is immediately provisioned.
* **Persistent Host Keys**: SSH host keys are stored externally in an S3 (AWS), GCS (GCP) bucket, or Storage Account Blob Container (Azure). When the instance is recycled, the host keys are synchronized back, ensuring that SSH clients do not encounter "Remote Host Identification Changed" warnings.
* **Unattended Security Upgrades**: The operating system (Ubuntu) is automatically configured to install security patches and perform a reboot at a scheduled quiet hour if a kernel update requires it.
* **Central Logging**: The instance ships critical authentication logs (`/var/log/auth.log` and `/var/log/syslog`) to external services (AWS CloudWatch Logs, Google Cloud Logging, or Azure Log Analytics Workspace) so that access logs are retained even after the bastion is recycled.
* **Dynamic DNS / Public IP**: Upon booting, the bastion automatically registers its new public IP in Route53 (AWS) or Cloud DNS (GCP), or utilizes a dynamic Azure Public IP with a custom DNS label.
* **User Management**: You can disable root/sudo permissions for the default `ubuntu`/`azureuser` user and define a list of additional local or external users with their own SSH public keys.

## Repository Structure

* **[aws/](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/aws/)**: Terraform module for AWS Bastion.
* **[gcp/](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/gcp/)**: Terraform module for GCP Bastion.
* **[azure/](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/azure/)**: Terraform module for Azure Bastion.
* **[examples/](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/examples/)**: Example configurations demonstrating how to invoke the modules.

## Requirements

* **Terraform**: `>= 1.0` (Latest tested version is `1.9.0`)
* **AWS Provider**: `~> 4.0` (To retain support for S3 bucket objects and launch configurations)
* **GCP Provider**: `~> 4.0`
* **AzureRM Provider**: `~> 3.0`
* **Template Provider**: `>= 2.1.2`

## What to Configure Before Deploying

Before deploying these modules, ensure the following infrastructure and settings are prepared:

### For AWS Bastion:
1. **AWS Credentials**: Configure your AWS CLI or set environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`).
2. **Target Network**: Prepare an existing VPC and at least one public subnet ID (`vpc_subnet_ids`).
3. **S3 Bucket**: Pre-create an S3 bucket (`infrastructure_bucket`) for persistent SSH host keys.
4. **SSH Key**: Have an SSH public key content ready to associate with the default `ubuntu` user (`ssh_public_key_file`).
5. **(Optional) Route53 Zone**: If you wish to enable automatic A-record registration, provide the Hosted Zone ID (`route53_zone_id`).

### For GCP Bastion:
1. **GCP Project**: Configure access to your GCP project (`gcloud auth application-default login`).
2. **Target Network**: Ensure a VPC network (`network_name`) and public subnetwork (`subnetwork_name`) are configured.
3. **GCS Bucket**: Pre-create a Google Cloud Storage bucket (`infrastructure_bucket`) for persistent SSH host keys.
4. **SSH Key**: Provide the public key content (`ssh_public_key_file`).
5. **(Optional) Cloud DNS Zone**: Provide the Managed Zone name (`dns_zone_name`) to enable Dynamic DNS updates on boot.

### For Azure Bastion:
1. **Azure Credentials**: Log in to Azure via Azure CLI (`az login`).
2. **Target Network**: Ensure an existing Resource Group (`resource_group_name`), Virtual Network, and Subnet (`subnet_id`) are ready.
3. **Storage Account**: Pre-create an Azure Storage Account (`infrastructure_storage_account_id`) and a private blob container (`infrastructure_storage_container_name`) to store SSH host keys.
4. **SSH Key**: Provide the public key content (`ssh_public_key_file`) to assign to the default VM administrator.
5. **Log Analytics Workspace**: Pre-create a Log Analytics Workspace (`log_analytics_workspace_id`) to gather syslog and auth logs.

---

## CI/CD Pipeline & Mock Deployments

This repository has a built-in CI/CD pipeline managed via **GitHub Actions** ([.github/workflows/terraform.yml](file:///Users/aleksandrandreichenko/work/github/module-tf-bastion/.github/workflows/terraform.yml)):

1. **Lint & Validate (CI)**: On every push and Pull Request, the pipeline runs code format check (`terraform fmt`) and code validation (`terraform validate`) using Terraform **1.9.0** for AWS, GCP, and Azure examples.
2. **Deploy (CD Mock)**: When changes are merged into the `master` branch and the validation step passes, the pipeline initiates a simulated deploy job (`deploy_mock`). This step mocks out the `terraform plan` and `terraform apply` stages, printing deployment step logs and mock output variables for demonstration.
