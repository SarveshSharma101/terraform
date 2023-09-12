resource "google_compute_network_endpoint_group" "neg" {
  name         = "${var.project_name}-my-lb-neg"
  network      = var.vpc
  subnetwork   = var.subnet
  default_port = var.default_port
  zone         = var.zone
}