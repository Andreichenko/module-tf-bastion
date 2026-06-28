terraform {
  required_version = ">= 0.14"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.1.2"
    }
  }
}