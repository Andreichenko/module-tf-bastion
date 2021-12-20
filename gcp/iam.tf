# Create a service account and IAM permissions for the bastion compute instance.

resource "google_service_account" "bastion" {
  account_id   = var.bastion_name
  display_name = "${var.bastion_name} bastion access to the project"
}


resource "google_project_iam_member" "bastion_dns" {
  role = "roles/dns.admin"

  member = "serviceAccount:${google_service_account.bastion.email}"
}