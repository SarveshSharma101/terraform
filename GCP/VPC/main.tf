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

resource "google_compute_network" "vpc_network" {
  name                    = "tf-vpc-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "pvt-sub" {
	name = "tf-pvt"
	ip_cidr_range = "10.0.0.0/16"
	region = "us-central1"
	network = google_compute_network.vpc_network.id
}


resource "google_compute_subnetwork" "pub-sub" {
	name = "tf-pub"
	ip_cidr_range = "10.1.0.0/16"
	region = "us-central1"
	network = google_compute_network.vpc_network.id
}

resource "google_compute_instance" "tf-pvt-vm" {
	name = "tf-pvt-vm"
	machine_type = "e2-micro"
	zone = "us-central1-a"

	network_interface {
		network = google_compute_network.vpc_network.name
		subnetwork = google_compute_subnetwork.pvt-sub.name

		
		
	}
	tags = ["pvt"]
	labels = {
	"owner" = "terraform"
	"env" = "pvt"
	"instance" = "1"
	}
	boot_disk {
		initialize_params {
			image = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
			size = 30
			type = "pd-balanced"
			labels = {
				"instace" : "1"
			}
		}
	}
}

resource "google_compute_instance" "tf-pub-vm" {
	name = "tf-pub-vm"
	machine_type = "e2-micro"
	zone = "us-central1-b"

	network_interface {
		network = google_compute_network.vpc_network.name
		subnetwork = google_compute_subnetwork.pub-sub.name

		access_config {
			
		}
		
	}

	tags = ["pub"]
	labels = {
	"owner" = "terraform"
	"env" = "pub"
	"instance" = "1"
	}
	boot_disk {
		initialize_params {
			image = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
			size = 30
			type = "pd-balanced"
			labels = {
				"instace" : "1"
			}
		}
	}
}

resource "google_compute_firewall" "allow-ssh" {
	name = "allow-ssh"

	network = google_compute_network.vpc_network.name
	allow {
		protocol = "tcp"
		ports = ["22"]
	}
	source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow-tcp-pub" {
	name = "allow-tcp-pub"

	network = google_compute_network.vpc_network.name
	allow {
		protocol = "tcp"
		ports = ["80"]
	}
	source_ranges = ["0.0.0.0/0"]
	target_tags = ["pub"]
}

resource "google_compute_router" "tf-pvt-router" {
	name = "tf-pvt-router"
	network = google_compute_network.vpc_network.name
	region = google_compute_subnetwork.pvt-sub.region

}

resource "google_compute_router_nat" "tf-pvt-nat" {
	name = "tf-pvt-nat"
	router = google_compute_router.tf-pvt-router.name
	region = google_compute_subnetwork.pvt-sub.region
	nat_ip_allocate_option             = "AUTO_ONLY"
	source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

}