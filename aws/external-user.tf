# This template data source is created for each user specified in the additional_users module input.
# The below template(s) will be rendered in the bastion-userdata.tmpl template.
data "template_file" "additional_user" {
  count = length(var.additional_users)