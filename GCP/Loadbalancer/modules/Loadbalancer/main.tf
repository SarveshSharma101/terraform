
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
    group           = var.lb-backend
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

# health check
resource "google_compute_health_check" "default" {
  name     = "lb-hc"
  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }
  
}
