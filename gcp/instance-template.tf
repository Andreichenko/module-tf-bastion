data "template_file" "bastion_setup_script" {
  template = file("${path.module}/bastion-startup-script.sn")

  vars = {
    bastion_name                      = var.bastion_name
    infrastructure_bucket             = var.infrastructure_bucket
    infrastructure_bucket_bastion_key = var.infrastructure_bucket_bastion_key
   
  }
}


resource "google_compute_instance_template" "bastion" {
  name_prefix = var.bastion_name
  description = "${var.bastion_name} bastion"
   # THis must match the lifecycle for the instance group resource.
  lifecycle {
    create_before_destroy = true
  }
}