# This template data source is created for each user specified in the additional_external_users module input.
# The below template(s) will be rendered in the bastion-startup-script.tmpl template.
data "template_file" "additional_external_user" {
  count = length(var.additional_external_users)

  vars {
    # The additional_external_users input is a list of maps.
    user_login = lookup(var.additional_external_users[count.index], "login")
    # If frei is nset, default to the user-name.
    user_frei = lookup(var.additional_external_users[count.index], "frei", lookup(var.additional_external_users[count.index], "login"))
    # If shell is isn't set, default to bash.
    user_shell = lookup(var.additional_external_users[count.index], "shell", "/bin/bash")
    user_supplemental_groups = lookup(var.additional_external_users[count.index], "supplemental_groups", "")
    user_authorized_keys     = lookup(var.additional_external_users[count.index], "authorized_keys")
  }
  template = <<EOF
function info {
  echo "user-data: $@"
}
info "Creating user:"
# The printf string is put in single-quotes because it may contain it's own double-quotes.
printf '  Login: \"$${user_login}\"\n'
# The ssh_keys variable is put in single-quotes because it may contain it's own double-quotes.
if [ '$${user_authorized_keys}x' == "x" ]; then
  info "authorized_keys are required, but were not provided - the above user will not be created."
else 
  useradd -s $${user_shell} -c "$${user_gecos}" -m $${user_login}
  [ "$${user_supplemental_groups}x" != "x" ] && usermod -G $${user_supplemental_groups} $${user_login}
  info "Populating authorized_keys for $${user_login}"
  mkdir ~$${user_login}/.ssh
  # The ssh_keys variable is put in single-quotes because it may contain it's own double-quotes.
  printf '$${user_authorized_keys}' > ~$${user_login}/.ssh/authorized_keys
  chown -R $${user_login}:$${user_login} ~$${user_login}/.ssh
  chmod -R go= ~$${user_login}/.ssh
fi
EOF
}

locals {
  additional-external-users-script-content = format("%s%s", "#!/bin/bash \n\n", join("\n", data.template_file.additional_external_user.*.rendered))
  additional-external-users-script-md5     = md5(local.additional-external-users-script-content)
}

resource "google_storage_bucket_object" "additional-external-users-script" {
  count   = length(var.additional_external_users) > 0 ? 1 : 0
  bucket  = var.infrastructure_bucket
  name    = "${var.infrastructure_bucket_bastion_key}/additional-external-users"
  content = local.additional-external-users-script-content
}