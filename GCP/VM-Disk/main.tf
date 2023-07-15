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

resource "google_compute_resource_policy" "disk-snapshot-1" {
	name = "disk-snapshot-1"
	region = "asia-south1"
	snapshot_schedule_policy {
		schedule {
			daily_schedule {
				days_in_cycle = 1
				start_time = "06:00"
			}
		}

		retention_policy {
			max_retention_days = 10
			on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
		}

		snapshot_properties {
			labels = {
				disk = "disk-snapshot-1"
				storage_locations = "asia"
			}
		}	
	}
}

resource "google_compute_resource_policy" "disk-snapshot-2" {
	name = "disk-snapshot-2"
	region = "asia-south1"
	snapshot_schedule_policy {
		schedule {
			hourly_schedule {
				hours_in_cycle = 6
				start_time = "00:00"
			}
		}

		retention_policy {
			max_retention_days = 30
			on_source_disk_delete = "KEEP_AUTO_SNAPSHOTS"
		}

		snapshot_properties {
			labels = {
				disk = "disk-snapshot-1"
				storage_locations = "asia-south1"
			}
		}	
	}
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

resource "google_compute_disk_resource_policy_attachment" "attachment1" {
	name = google_compute_resource_policy.disk-snapshot-1.name
	disk = google_compute_disk.disk-t-ce-1.name
	zone = google_compute_disk.disk-t-ce-1.zone
}

resource "google_compute_region_disk_resource_policy_attachment" "attachment2" {
	name = google_compute_resource_policy.disk-snapshot-2.name
	disk = google_compute_region_disk.disk-t-ce-2.name
	region = "asia-south1"
}


resource "google_storage_bucket" "sotrage_bucket" {
	name = "sotrage_bucket1"
	location = "US"
	storage_class = "STANDARD"
	uniform_bucket_level_access = true
	versioning {
		enabled = true
	}
	force_destroy = true
}

resource "google_storage_bucket_object" "dummy" {
	name = "dummy"
	source = "dummy.txt"
	content_type = "text/plain"
	bucket = google_storage_bucket.sotrage_bucket.id
}