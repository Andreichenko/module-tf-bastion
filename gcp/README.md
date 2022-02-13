# Terraform GCP Bastion Module

This module manages a Google Cloud bastion compute instance and its regional Auto Scaling Group, service account, SSH firewall rule, and SSH access. The Auto Scaling Group will recreate the bastion if there is an issue with the compute instance or the availability zone where it is running.

TODO should create some impelmentation 