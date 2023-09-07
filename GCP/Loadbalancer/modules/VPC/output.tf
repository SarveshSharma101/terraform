output "vpc" {
    value = {
        vpc = google_compute_network.vpc
        private-subnet = google_compute_subnetwork.private-subnets
        public-subnet = google_compute_subnetwork.public-subnets
    }
}