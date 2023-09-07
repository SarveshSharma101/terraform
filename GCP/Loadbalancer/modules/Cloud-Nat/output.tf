output "cloud-nat" {
    value = {
        cloud-nat = google_compute_router_nat.pvt-nat
    }
}