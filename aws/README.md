# Terraform AWS Bastion Module

This module manages an Amazon Web Services bastion EC2 instance and its Auto Scaling Group, Instance Profile / Role, CloudWatch Log Group, Security Group, and SSH Key Pair. The Auto Scaling Group will recreate the bastion if there is an issue with the EC2 instance or the availability zone where it is running.