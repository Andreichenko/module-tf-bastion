terraform {
  required_version = ">= 0.14"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 2.0.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.1.2"
    }
  }
}

provider "google" {
  project = "my-gcp-project-id"
  region  = "us-central1"
}

# Example GCS bucket for storing persisting data like SSH host keys
resource "google_storage_bucket" "infra_bucket" {
  name          = "my-bastion-infra-bucket-unique"
  location      = "US"
  force_destroy = true

  versioning {
    enabled = true
  }
}

# Example Network and Subnetwork (replace with your actual network configuration)
resource "google_compute_network" "main" {
  name                    = "bastion-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public" {
  name          = "bastion-subnetwork"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.main.id
}

# DNS Zone to manage register-dns on boot
resource "google_dns_managed_zone" "bastion_zone" {
  name     = "bastion-zone"
  dns_name = "bastion.example.com."
}

module "gcp_bastion" {
  source = "../../gcp"

  bastion_name           = "production-bastion"
  region                 = "us-central1"
  availability_zones     = ["us-central1-a", "us-central1-b"]
  infrastructure_bucket  = google_storage_bucket.infra_bucket.name
  dns_zone_name          = google_dns_managed_zone.bastion_zone.name
  network_name           = google_compute_network.main.name
  subnetwork_name        = google_compute_subnetwork.public.name
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
