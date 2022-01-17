This module manages a Google Cloud bastion compute instance and its regional Auto Scaling Group, service account, SSH firewall rule, and SSH access. The Auto Scaling Group will recreate the bastion if there is an issue with the compute instance or the availability zone where it is running.

The startup script assumes the Ubuntu operating system, which is configured as follows:

Packages are updated, and the bastion is rebooted if required.
If SSH hostkeys are present in the configurable GCS bucket and path, they are copied to the bastion to retain its previous SSH identity. If there are no host keys in GCS, the current keys are copied there.
The Google Accounts daemon is disabled so that SSH access is managed exclusively by this module. This disables the ability to use gcloud compute ssh ... to SSH to the bastion.
The [Stackdriver Logging agent][] is installed and configured to ship logs from these files:
'''/var/log/syslog'''
'''/var/log/auth.log'''
A host record, named using the bastion_name module input, is added to a configurable Google DNS managed DNS zone for the current public IP address of the bastion. This happens via a script configured to run each time the bastion boots.
Automatic updates are configured, using a configurable time to reboot, and the email address to receive errors.
By default sudo access is removed from the ubuntu user unless the remove_root_access input is set to "false."
Additional startup script commands can be executed, for one-off configuration not included in this module.
Additional users can be created and populated with their own authorized_keys file.