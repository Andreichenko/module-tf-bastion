locals {
  additional-external-users-script-content = format("%s%s", "#!/bin/bash \n\n", join("\n", data.template_file.additional_external_user.*.rendered))
  additional-external-users-script-md5     = md5(local.additional-external-users-script-content)
}

resource "aws_s3_bucket_object" "additional-external-users-script" {
  bucket  = local.infrastructure_bucket.id
  key     = "${var.infrastructure_bucket_bastion_key}/additional-external-users"
  content = local.additional-external-users-script-content
  etag    = md5(local.additional-external-users-script-content)
}