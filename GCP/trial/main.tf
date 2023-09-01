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

resource "google_compute_instance_template" "example_template" {
  name = "example-template"

  properties = {
    machine_type = "n1-standard-1"

    metadata_startup_script = <<-EOT
      #!/bin/bash
      echo "Hello, world!" > /tmp/temp.txt
    EOT

    // Other instance properties like image, tags, etc.
  }
}

resource "google_compute_instance_group_manager" "example_mig" {
  name = "example-mig"

  base_instance_name = "example-instance"
  instance_template = google_compute_instance_template.example_template.self_link
  target_size       = 2 // Adjust the desired number of instances

  // Auto-healing settings, health check, etc.
}