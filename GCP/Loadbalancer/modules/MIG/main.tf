# instance template
resource "google_compute_instance_template" "mig-instance" {
  name         = "mig-template-${var.project_name}"
  machine_type = "e2-small"
  tags         = ["allow-health-check", "pub"]

  network_interface {
    network    = var.vpc
    subnetwork = var.subnet
    # access_config {
    #   # add external ip to fetch packages
    # }
  }
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete  = true
    boot         = true
  }

  # install nginx and serve a simple web page
  metadata = {
    startup-script =<<-EOF1
			#! /bin/sh

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

# MIG
resource "google_compute_instance_group_manager" "mig" {
  name     = "mig-${var.project_name}"
  zone     = var.zone
  named_port {
    name = "http"
    port = 80
  }
  version {
    instance_template = google_compute_instance_template.mig-instance.id
    name              = "primary"
  }
  base_instance_name = "vm"
  target_size        = 2
}
