#!/bin/bash


# Output information about what this script is doing.
function info {
  echo "startup-script: $@"
}

# GCP startup scripts are run on each boot.
info Determining whether this script has been run before. . .
if [ -r /metadata_startup_script-has_run ] ; then
info THis script has been run, as the /metadata_startup_script-has_run file exists.
info Exiting...
exit 0
fi
touch /metadata_startup_script-has_run


info Disabling GCE managed Linux users and SSH access.
cat <<EOT >/etc/default/instance_configs.cfg.template
[Daemons]
accounts_daemon = false
EOT
/usr/bin/google_instance_setup
# The above does not stop the google-accounts service immediately.
systemctl stop google-accounts-daemon.service
systemctl disable google-accounts-daemon.service


# RE: the UCF options below,
# see https://askubuntu.com/questions/146921/how-do-i-apt-get-y-dist-upgrade-without-a-grub-config-prompt
# Keep the old menu.lst file as it provides compute instance console output.
export UCF_FORCE_CONFFOLD=yes
#export UCF_FORCE_CONFFNEW=yes
ucf --purge /boot/grub/menu.lst
export DEBIAN_FRONTEND=noninteractive
info Updating packages. . .
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" update

info Triggering a job using at, to sleep then run apt-get upgrade...
echo "sleep 120 ; apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade" |at now

info Installing packages needed on the bastion...
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install python unattended-upgrades

info The infra bucket is: ${infrastructure_bucket} and the GCS key is ${infrastructure_bucket_bastion_key}

info Looking for SSHd host keys to copy from GCS. . .
gsutil list gs://${infrastructure_bucket}/${infrastructure_bucket_bastion_key}/sshd/ssh_host_rsa_key >/dev/null
if [ $? -eq 0 ] ; then
info Syncing host keys from ${infrastructure_bucket}/${infrastructure_bucket_bastion_key}
gsutil rsync gs://${infrastructure_bucket}/${infrastructure_bucket_bastion_key}/sshd/ /etc/ssh/
  chmod go= /etc/ssh/ssh_host_*_key
  info Restarting sshd to use new host keys
  systemctl restart ssh
else
  info Copying host keys to GCS, this must be the first ever bastion instance using ${infrastructure_bucket}/${infrastructure_bucket_bastion_key}...
  for n in `ls -c1 /etc/ssh/ssh_host_*`;
  do
   gsutil cp $n gs://${infrastructure_bucket}/${infrastructure_bucket_bastion_key}/sshd/
  done
fi

info Configuring unattended upgrades in /etc/apt/apt.conf.d/50unattended-upgrades
cat <<EOF >>/etc/apt/apt.conf.d/50unattended-upgrades
// Options added by user-data and Terraform:
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "${unattended_upgrade_reboot_time}";
Unattended-Upgrade::MailOnlyOnError "true";
Unattended-Upgrade::Mail "${unattended_upgrade_email_recipient}";
${unattended_upgrade_additional_configs}
EOF

# Execute optional additional user data.
if [ "$${additional_setup_script}x" == "x" ] ; then
  info "Executing additional_setup_script. . ."
  ${additional_setup_script}
  info "Finished executing additional_setup_script. . ."
fi

# Add optional additional users and authorized_keys,
# specified in the additional_users module input as a list of maps.
# This variable is set to the rendering of all additional user templates,
# which are shell commands to be executed to create and configure the users.
${additional_user_templates}

# run the additional-external-users.sh script from GCS
info Running the additional-external-users script -- check systemctl or journalctl additional-external-users to see output
gsutil cp gs://${infrastructure_bucket}/${infrastructure_bucket_bastion_key}/additional-external-users /usr/local/bin/additional-external-users
info using md5 ${additional-external-users-script-md5}
chmod +x /usr/local/bin/additional-external-users

info Installing the additional-external-users systemd service
cat <<EOF >/etc/systemd/system/additional-external-users.service
[Unit]
Description=Add all defined additional external users to the bastion
[Service]
ExecStart=/usr/local/bin/additional-external-users
Type=oneshot
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable additional-external-users
systemctl start additional-external-users

# Use a temporary variable to more easily compare the lowercase remove_root_access input.
rra=$(echo ${remove_root_access} |tr '[:upper:]' '[:lower:]')
if test $rra == "true" -o $rra == "yes" -o $rra == "1" ; then
  info Removing root access from the ubuntu user as remove_root_access is set to $rra
  # The ubuntu user has sudo access via both a group and configuration from cloudinit.
  rm -f /etc/sudoers.d/90-cloud-init-users
  deluser ubuntu sudo
else
  info Retaining root access as remove_root_access is set to \"$rra\"
fi

info Rebooting, if required by any kernel updates earlier
test -r /var/run/reboot-required && echo Reboot is required, doing that now... && shutdown -r +1 'bastion setup-script rebooting after package updates...'
