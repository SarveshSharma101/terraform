resource "google_compute_router" "pvt-router" {
	name = "pvt-router-${var.project_name}"
	network = var.vpc
	region = var.region

}

resource "google_compute_router_nat" "pvt-nat" {
	name = "pvt-nat-${var.project_name}"
	router = google_compute_router.pvt-router.name
	region = var.region
	nat_ip_allocate_option             = "AUTO_ONLY"
	source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}