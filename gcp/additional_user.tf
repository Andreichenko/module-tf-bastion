data "template_file" "additional_user" {
  count = length(var.additional_users)

  vars = {
        # The additional_users input is a list of maps.
    user_login = lookup(var.additional_users[count.index], "login")
    # If gecos is nset, default to the user-name.
    user_gecos = lookup(
      var.additional_users[count.index],
      "gecos",
      lookup(var.additional_users[count.index], "login"),
    )
    # If shell is isn't set, default to bash.
    user_shell               = lookup(var.additional_users[count.index], "shell", "/bin/bash")
    user_supplemental_groups = lookup(var.additional_users[count.index], "supplemental_groups", "")
    user_authorized_keys     = lookup(var.additional_users[count.index], "authorized_keys")
  }
  template = <<EOF
  info "Creating user:"
  EOF
}