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