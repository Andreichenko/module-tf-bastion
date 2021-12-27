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
  service_account {
    email = google_service_account.bastion.email
    disk {
    source_image = data.google_compute_image.ubuntu.self_link
    auto_delete  = true
    boot         = true
  }

    # Best practice is to use IA M roles to narrow permissions granted by scopes.
    scopes = ["compute-ro", "storage-rw", "https://www.googleapis.com/auth/ndev.clouddns.readwrite"]
  }
  network_interface {
    subnetwork = var.subnetwork_name
    # This is required to configure a public IP address.
    access_config {}
  }
   # THis must match the lifecycle for the instance group resource.
  lifecycle {
    create_before_destroy = true
  }
}