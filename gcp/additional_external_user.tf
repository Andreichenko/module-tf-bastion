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