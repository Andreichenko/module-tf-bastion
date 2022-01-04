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

info Installing and configuring the Stackdriver Logging agent
# Ref: https://cloud.google.com/logging/docs/agent/installation
curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
bash install-logging-agent.sh
rm -f install-logging-agent.sh
info Writing /etc/google-fluentd/config.d/syslog-auth.conf
cat <<EOF >/etc/google-fluentd/config.d/syslog-auth.conf
<source>
  @type tail
  # Parse the timestamp, but still collect the entire line as 'message'
  format /^(?<message>(?<time>[^ ]*\s*[^ ]* [^ ]*) .*)$/
  path /var/log/auth.log
  pos_file /var/lib/google-fluentd/pos/syslog-auth.pos
  read_from_head true
  tag syslog
</source>
EOF

info Restarting the google-fluentd service
systemctl restart google-fluentd.service

info Setting up DNS registration on boot
# Automatic external DNS registration is in alpha, not for prod use...
# info Creating the /usr/local/bin/register-dns script using Google DNS zone name ${zone_name}. . .


