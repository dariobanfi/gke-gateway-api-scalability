terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "certmanager_api" {
  project                    = var.project_id
  service                    = "certificatemanager.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}


resource "google_project_service" "gke_api" {
  project                    = var.project_id
  service                    = "container.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}


# Fetch default network details (optional but good practice)
data "google_compute_network" "default_network" {
  name = var.network_name
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  # Use the default network
  network    = data.google_compute_network.default_network.id
  subnetwork = "" # Let GKE choose a subnetwork in the default network for the region

  # Enable Autopilot
  enable_autopilot = true


  # Basic cluster settings (Autopilot manages most)
  initial_node_count = 1 # Required placeholder, Autopilot manages actual nodes
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Disable deletion protection for demo purposes
  deletion_protection = false
}

# Configure Kubernetes provider to connect to the created GKE cluster
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

# --- Kubernetes Resources ---

# Define the Namespace (optional, good practice)
resource "kubernetes_namespace" "app_ns" {
  metadata {
    name = "hello-app-ns"
  }

  # Ensure cluster is ready before creating namespace
  depends_on = [google_container_cluster.primary]
}


# Create a global static IP address for the load balancer
resource "google_compute_global_address" "static_ip_global" {
  name         = "lb-address"
  project      = var.project_id
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}


resource "google_dns_record_set" "lb_dns" {
  name         = "${var.wildcard_domain}."
  managed_zone = data.google_dns_managed_zone.demo_zone.name
  project      = "darioenv-clouddns"
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.static_ip_global.address]
}


# dns

resource "google_certificate_manager_dns_authorization" "default" {
  name        = "${var.cert_base_name}-dns-auth"
  project     = var.project_id
  location    = "global" 
  description = "DNS Authorization for ${var.base_domain_for_auth}"
  domain      = var.base_domain_for_auth
}

data "google_dns_managed_zone" "demo_zone" {
  name    = "dariobanfi-demo"
  project = "darioenv-clouddns"
}

resource "google_dns_record_set" "cert_validation" {
  name         = google_certificate_manager_dns_authorization.default.dns_resource_record[0].name
  managed_zone = data.google_dns_managed_zone.demo_zone.name
  project      = "darioenv-clouddns"
  type         = google_certificate_manager_dns_authorization.default.dns_resource_record[0].type
  ttl          = 300
  rrdatas      = [google_certificate_manager_dns_authorization.default.dns_resource_record[0].data]
}


resource "google_certificate_manager_certificate" "default" {
  name        = "${var.cert_base_name}-cert"
  project     = var.project_id
  location    = "global"
  description = "Managed certificate for ${var.wildcard_domain}"
  scope       = "DEFAULT" # Use DEFAULT for Google LBs, or EDGE_CACHE if for Media CDN.

  managed {
    domains = [var.wildcard_domain]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.default.id
    ]
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_certificate_manager_certificate_map" "default" {
  name        = "${var.cert_base_name}-cert-map"
  project     = var.project_id
  description = "Certificate Map for ${var.wildcard_domain}"
}

resource "google_certificate_manager_certificate_map_entry" "default" {
  name         = "${var.cert_base_name}-map-entry"
  project      = var.project_id
  map          = google_certificate_manager_certificate_map.default.name
  description  = "Map entry for ${var.wildcard_domain}"
  hostname    = var.wildcard_domain
  certificates = [google_certificate_manager_certificate.default.id]

  depends_on = [google_certificate_manager_certificate.default]
}
