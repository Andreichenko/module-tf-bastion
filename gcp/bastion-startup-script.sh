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

