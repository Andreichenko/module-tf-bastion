data "azurerm_storage_account" "infra" {
  name                = element(split("/", var.infrastructure_storage_account_id), length(split("/", var.infrastructure_storage_account_id)) - 1)
  resource_group_name = element(split("/", var.infrastructure_storage_account_id), 4)
}

# This template data source is created for each user specified in the additional_users module input.
data "template_file" "additional_user" {
  count = length(var.additional_users)

  vars = {
    user_login = lookup(var.additional_users[count.index], "login")
    user_gecos = lookup(
      var.additional_users[count.index],
      "gecos",
      lookup(var.additional_users[count.index], "login")
    )
    user_shell               = lookup(var.additional_users[count.index], "shell", "/bin/bash")
    user_supplemental_groups = lookup(var.additional_users[count.index], "supplemental_groups", "")
    user_authorized_keys     = lookup(var.additional_users[count.index], "authorized_keys")
  }

  template = <<EOF
info "Creating user:"
printf '  Login: \"$${user_login}\"\n'

if [ '$${user_authorized_keys}x' == "x" ]; then
  info "authorized_keys are required, but were not provided - the above user will not be created."
else
  useradd -s $${user_shell} -c "$${user_gecos}" -m $${user_login}
  [ "$${user_supplemental_groups}x" != "x" ] && usermod -G $${user_supplemental_groups} $${user_login}
  info "Populating authorized_keys for $${user_login}"
  mkdir ~$${user_login}/.ssh
  printf '$${user_authorized_keys}' > ~$${user_login}/.ssh/authorized_keys
  chown -R $${user_login}:$${user_login} ~$${user_login}/.ssh
  chmod -R go= ~$${user_login}/.ssh
fi
EOF
}

# This template data source is created for each user specified in the additional_external_users module input.
data "template_file" "additional_external_user" {
  count = length(var.additional_external_users)

  vars = {
    user_login = lookup(var.additional_external_users[count.index], "login")
    user_gecos = lookup(
      var.additional_external_users[count.index],
      "gecos",
      lookup(var.additional_external_users[count.index], "login")
    )
    user_shell               = lookup(var.additional_external_users[count.index], "shell", "/bin/bash")
    user_supplemental_groups = lookup(var.additional_external_users[count.index], "supplemental_groups", "")
    user_authorized_keys     = lookup(var.additional_external_users[count.index], "authorized_keys")
  }

  template = <<EOF
function info {
  echo "user-data: $@"
}
info "Creating user:"
printf '  Login: \"$${user_login}\"\n'
if [ '$${user_authorized_keys}x' == "x" ]; then
  info "authorized_keys are required, but were not provided - the above user will not be created."
else 
  useradd -s $${user_shell} -c "$${user_gecos}" -m $${user_login}
  [ "$${user_supplemental_groups}x" != "x" ] && usermod -G $${user_supplemental_groups} $${user_login}
  info "Populating authorized_keys for $${user_login}"
  mkdir ~$${user_login}/.ssh
  printf '$${user_authorized_keys}' > ~$${user_login}/.ssh/authorized_keys
  chown -R $${user_login}:$${user_login} ~$${user_login}/.ssh
  chmod -R go= ~$${user_login}/.ssh
fi
EOF
}

locals {
  additional_external_users_script_content = format("%s%s", "#!/bin/bash \n\n", join("\n", data.template_file.additional_external_user.*.rendered))
  additional_external_users_script_md5     = md5(local.additional_external_users_script_content)
}

resource "azurerm_storage_blob" "additional_external_users_script" {
  count                  = length(var.additional_external_users) > 0 ? 1 : 0
  name                   = "additional-external-users"
  storage_account_name   = data.azurerm_storage_account.infra.name
  storage_container_name = var.infrastructure_storage_container_name
  type                   = "Block"
  source_content         = local.additional_external_users_script_content
}
