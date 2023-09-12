resource "google_compute_network_endpoint" "default-endpoint" {
  count                  = length(var.instance)
  network_endpoint_group = var.neg_name
  zone                   = var.zone
  instance               = var.instance[count.index]
  port                   = var.default_port
  ip_address             = var.instance_network_ip[count.index]
  depends_on             = [null_resource.delay]
}

resource "null_resource" "delay" {
  # This resource does nothing except introduce a delay
  triggers = {
    delay = "${timestamp()}"
  }

  provisioner "local-exec" {
    # Sleep for 5 seconds before proceeding
    command = "sleep 30"
  }
}