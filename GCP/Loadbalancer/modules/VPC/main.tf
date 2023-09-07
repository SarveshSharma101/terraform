terraform {
	required_providers {
		google = {
			source = "hashicorp/google"
    version = "4.51.0"
		}
	}
}

provider "google" {
	credentials = file("/mnt/c/Users/ppain/Desktop/mws/t-key/terraform-practice-392512-379f604ce6fb.json")

	project = "terraform-practice-392512"
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "vpc-${var.project_name}"
  auto_create_subnetworks = false
  mtu                     = 1460
}

# public subnet
resource "google_compute_subnetwork" "public-subnets" {
	count = var.pub_subnet_count
  name          = "pub-subnet-${count.index+1}"
  ip_cidr_range = cidrsubnet("10.0.0.0/16", 8, count.index)
  region        = var.public_region
  network       = google_compute_network.vpc.id
}

# private subnet
resource "google_compute_subnetwork" "private-subnets" {
	count = var.private_subnet_count
  name          = "private-subnet-${count.index+1}"
  ip_cidr_range = cidrsubnet("10.1.0.0/20", 8, count.index)
  region        = var.private_region
  network       = google_compute_network.vpc.id
}


# allow access from health check ranges
resource "google_compute_firewall" "default" {
  name          = "l7-xlb-fw-allow-hc"
  direction     = "INGRESS"
  network       = google_compute_network.vpc.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
		ports = ["80"]
  }
  target_tags = ["allow-health-check"]
}

resource "google_compute_firewall" "allow-tcp-pub" {
	name = "allow-tcp-pub"

	network = google_compute_network.vpc.id
	allow {
		protocol = "tcp"
		ports = ["80"]
	}
	source_ranges = [var.internet]
	target_tags = ["pub"]
}

resource "google_compute_firewall" "allow-ssh" {
	name = "allow-ssh"

	network = google_compute_network.vpc.id
	allow {
		protocol = "tcp"
		ports = ["22"]
	}
	source_ranges = [var.internet]
}