# Terraform AWS Bastion Module

This module manages an Amazon Web Services bastion EC2 instance and its Auto Scaling Group, Instance Profile / Role, CloudWatch Log Group, Security Group, and SSH Key Pair. The Auto Scaling Group will recreate the bastion if there is an issue with the EC2 instance or the availability zone where it is running.

The EC2 UserData assumes the Ubuntu operating system, which is configured as follows:

Packages are updated, and the bastion is rebooted if required.
If SSH hostkeys are present in the configurable S3 bucket and path, they are copied to the bastion to retain its previous SSH identity. If there are no host keys in S3, the current keys are copied there.
The CloudWatch Logs Agent is installed and configured to ship logs from these files:
/var/log/syslog
/var/log/auth.log
A host record, named using the bastion_name module input, is added to a configurable Route53 DNS zone for the current public IP address of the bastion. This happens via a script configured to run each time the bastion boots.
Automatic updates are configured, using a configurable time to reboot, and the email address to receive errors.
By default sudo access is removed from the ubuntu user unless the remove_root_access input is set to "false."
Additional EC2 User Data can be executed, for one-off configuration not included in this module.
Additional users can be created and populated with their own authorized_keys file.


TODO should create some impelmentation 