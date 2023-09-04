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
resource "google_compute_network" "default" {
  name                    = "lb-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

# backend subnet
resource "google_compute_subnetwork" "default" {
  name          = "lb-backend-subnet"
  ip_cidr_range = var.vpc-subnet-1
  region        = var.region
  network       = google_compute_network.default.id
}

# reserved IP address
resource "google_compute_global_address" "default" {
  name     = "lb-static-ip"
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "lb-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}

# http proxy
resource "google_compute_target_http_proxy" "default" {
  name     = "lb-target-http-proxy"
  url_map  = google_compute_url_map.default.id
}

# url map
resource "google_compute_url_map" "default" {
  name            = "lb-url-map"
  default_service = google_compute_backend_service.default.id
}

# backend service with custom request and response headers
resource "google_compute_backend_service" "default" {
  name                    = "lb-backend-service"
  protocol                = "HTTP"
  port_name               = "http"
  load_balancing_scheme   = "EXTERNAL"
  timeout_sec             = 10
  enable_cdn              = true
  # custom_request_headers  = ["X-Client-Geo-Location: {client_region_subdivision}, {client_city}"]
  # custom_response_headers = ["X-Cache-Hit: {cdn_cache_status}"]
  health_checks           = [google_compute_health_check.default.id]
  backend {
    group           = !var.use-custom-backend ? google_compute_instance_group_manager.default.instance_group : var.lb-backend
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# instance template
resource "google_compute_instance_template" "default" {
  name         = "lb-mig-template"
  machine_type = "e2-small"
  tags         = ["allow-health-check", "pub"]

  network_interface {
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.default.id
    access_config {
      # add external ip to fetch packages
    }
  }
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }

  # install nginx and serve a simple web page
  metadata = {
    startup-script = <<-EOF1
			#! /bin/bash

			sudo apt-get install -y apache2
			sudo apt-get install -y jq
			NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
			IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
			METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')

			sudo cat <<EOF > /var/www/html/index.html
			<pre>
			Name: $NAME
			IP: $IP
			Metadata: $METADATA
			</pre>
			EOF
    EOF1
  }
  lifecycle {
    create_before_destroy = true
  }
}

# health check
resource "google_compute_health_check" "default" {
  name     = "lb-hc"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
  
}

# MIG
resource "google_compute_instance_group_manager" "default" {
  name     = "lb-mig1"
  zone     = var.mig-zone
  named_port {
    name = "http"
    port = 80
  }
  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}

# allow access from health check ranges
resource "google_compute_firewall" "default" {
  name          = "l7-xlb-fw-allow-hc"
  direction     = "INGRESS"
  network       = google_compute_network.default.id
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  allow {
    protocol = "tcp"
		ports = ["80"]
  }
  target_tags = ["allow-health-check"]
}
resource "google_compute_firewall" "allow-tcp-pub" {
	name = "allow-tcp-pub"

	network = google_compute_network.default.id
	allow {
		protocol = "tcp"
		ports = ["80"]
	}
	source_ranges = [var.internet]
	target_tags = ["pub"]
}

resource "google_compute_firewall" "allow-ssh" {
	name = "allow-ssh"

	network = google_compute_network.default.id
	allow {
		protocol = "tcp"
		ports = ["22"]
	}
	source_ranges = [var.internet]
}