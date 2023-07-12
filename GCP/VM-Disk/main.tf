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

resource "google_compute_instance" "instace1" {
	name = "t-ce-1"
	machine_type = "e2-micro"

	zone = "asia-south1-c"
	description = "VM instances practice using terraform. Instance-1"

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


	network_interface {
		network = "default"

		access_config {
      // Ephemeral public IP
    }
	}
	
	labels = {
		"owner" = "terraform"
		"env" = "practice"
		"instance" = "1"
	}

		attached_disk {
		source = google_compute_disk.disk-t-ce-1.name
	}
}

resource "google_compute_instance" "instace2" {
	name = "t-ce-2"
	machine_type = "e2-micro"

	zone = "asia-south1-a"
	description = "VM instances practice using terraform. Instance-2"

	boot_disk {
		initialize_params {
			image = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
			size = 30
			type = "pd-balanced"
			labels = {
				"instace" : "2"
			}
		}
	}


	network_interface {
		network = "default"
		access_config {
      // Ephemeral public IP
    }
	}
	
	labels = {
		"owner" = "terraform"
		"env" = "practice"
		"instance" = "2"
	}

	attached_disk {
		source = google_compute_region_disk.disk-t-ce-2.self_link
	}
	# depends_on = [ google_compute_region_disk.disk-t-ce-2 ]
}

resource "google_compute_firewall" "web-rule" {
	name = "web-rule"
	network = "default"
	priority = "1000"

	allow {
		protocol = "tcp"
		ports = [ "80", "443" ]
	}

	source_ranges = [ "0.0.0.0/0" ]
}

resource "google_compute_region_disk" "disk-t-ce-2" {
	name = "disk-t-ce-2"
	region = "asia-south1"
	replica_zones = [ "asia-south1-a", "asia-south1-b" ]

	type = "pd-balanced"

	size = 50
	
}

resource "google_compute_disk" "disk-t-ce-1" {
	name = "disk-t-ce-1"
	zone = "asia-south1-c"

	type = "pd-balanced"

	size = 50
	
}