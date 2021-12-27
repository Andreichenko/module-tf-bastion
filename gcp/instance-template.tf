data "template_file" "bastion_setup_script" {
  template = file("${path.module}/bastion-startup-script.sn")

  vars = {
    bastion_name                      = var.bastion_name
    infrastructure_bucket             = var.infrastructure_bucket
    infrastructure_bucket_bastion_key = var.infrastructure_bucket_bastion_key
   
  }
}
