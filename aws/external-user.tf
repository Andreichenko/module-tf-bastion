locals {
  additional-external-users-script-content = format("%s%s", "#!/bin/bash \n\n", join("\n", data.template_file.additional_external_user.*.rendered))
  additional-external-users-script-md5     = md5(local.additional-external-users-script-content)
}