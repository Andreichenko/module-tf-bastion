data "template_file" "additional_user" {
  count = length(var.additional_users)
}