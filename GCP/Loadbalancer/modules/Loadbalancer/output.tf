output "lb" {
  value = {
		externel_ip = google_compute_global_address.default
	}
}