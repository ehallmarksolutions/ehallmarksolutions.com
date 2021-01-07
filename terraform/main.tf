terraform {
  required_providers {
  }
}

provider "google" {
  version = "3.49.0"
  project = var.project_name
  region  = var.region
  zone    = var.location
}

resource "google_compute_network" "default" {
  name                    = var.project_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "default" {
  name                     = var.project_name
  ip_cidr_range            = "10.168.0.0/20"  // Change as per your region/zone (https://cloud.google.com/vpc/docs/vpc#ip-ranges)
  network                  = google_compute_network.default.self_link
  region                   = var.region
  private_ip_google_access = true
}

data "google_client_config" "current" {
}

data "google_container_engine_versions" "default" {
  location = var.location
}

// managed certificate to use with ingress lb
resource "google_compute_managed_ssl_certificate" "managed_certificate" {
  provider = google-beta
  name     = element(split(".", var.domain), 0)

  project = var.project_name

  managed {
    domains = [var.domain]
  }
}

// public ip reserved for ingress load balancer
resource "google_compute_global_address" "ingress_ip" {
  name = var.project_name
}

resource "google_container_cluster" "primary" {
  name     = var.project_name
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network            = google_compute_subnetwork.default.name
  subnetwork         = google_compute_subnetwork.default.name

  // Use legacy ABAC until these issues are resolved:
  //   https://github.com/mcuadros/terraform-provider-helm/issues/56
  //   https://github.com/terraform-providers/terraform-provider-kubernetes/pull/73
  enable_legacy_abac = true
  // Wait for the GCE LB controller to cleanup the resources.
  // Wait for the GCE LB controller to cleanup the resources.
  provisioner "local-exec" {
    when    = destroy
    command = "sleep 90"
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.project_name
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

  }
}