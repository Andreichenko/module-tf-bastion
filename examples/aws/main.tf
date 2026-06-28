terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.1.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Example S3 bucket for storing persisting data like SSH host keys
resource "aws_s3_bucket" "infra_bucket" {
  bucket_prefix = "bastion-infra-bucket-"
}

resource "aws_s3_bucket_ownership_controls" "infra_bucket" {
  bucket = aws_s3_bucket.infra_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "infra_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.infra_bucket]

  bucket = aws_s3_bucket.infra_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "infra_bucket" {
  bucket = aws_s3_bucket.infra_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Example VPC and Subnets (replace with your actual network configuration)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

module "aws_bastion" {
  source = "../../aws"

  bastion_name           = "production-bastion"
  infrastructure_bucket  = aws_s3_bucket.infra_bucket.id
  vpc_subnet_ids         = [aws_subnet.public_1.id]
  ssh_public_key_file    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ..." # Replace with actual public key
  
  unattended_upgrade_email_recipient = "admin@example.com"
  unattended_upgrade_reboot_time     = "03:00"

  remove_root_access = "true"

  additional_users = [
    {
      login           = "alice"
      gecos           = "Alice Developer"
      shell           = "/bin/bash"
      authorized_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQAB..."
    },
    {
      login           = "bob"
      gecos           = "Bob DevOps"
      shell           = "/bin/zsh"
      authorized_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQAB..."
    }
  ]

  additional_external_users = [
    {
      login           = "external-audit"
      gecos           = "External Auditor"
      shell           = "/bin/bash"
      authorized_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQAB..."
    }
  ]
}

output "bastion_security_group_id" {
  value = module.aws_bastion.security_group_id
}
