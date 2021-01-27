provider "kubernetes" {
  version = "~> 1.10.0"
  host    = google_container_cluster.primary.endpoint
  token   = data.google_client_config.current.access_token
  client_certificate = base64decode(
  google_container_cluster.primary.master_auth[0].client_certificate,
  )
  client_key = base64decode(google_container_cluster.primary.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(
  google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
}

resource "kubernetes_namespace" "default" {
  metadata {
    name = "website"
  }
}

resource "kubernetes_ingress" "site" {
  metadata {
    name=var.project_name
    namespace=kubernetes_namespace.default.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.global-static-ip-name" = google_compute_global_address.ingress_ip.name
      "ingress.gcp.kubernetes.io/pre-shared-cert" = google_compute_managed_ssl_certificate.managed_certificate.name
    }
  }

  spec {
    backend {
      service_name = kubernetes_service.site.metadata[0].name
      service_port = kubernetes_service.site.spec[0].port[0].port
    }
    rule {
      host = var.domain
      http {
        path {
          path = "/*"
          backend {
            service_name = kubernetes_service.site.metadata[0].name
            service_port = kubernetes_service.site.spec[0].port[0].port
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "site" {
  metadata {
    namespace = kubernetes_namespace.default.metadata[0].name
    name      = var.project_name
  }

  spec {
    selector = {
      run = var.project_name
    }

    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }
}

resource "kubernetes_config_map" "site" {
  metadata {
    name = var.project_name
    namespace = kubernetes_namespace.default.metadata[0].name
  }
  data = {
      ENVIRONMENT = "prod"
  }
}

resource "kubernetes_deployment" "site" {
  metadata {
    name      = var.project_name
    namespace = kubernetes_namespace.default.metadata[0].name

    labels = {
      run = var.project_name
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        run = var.project_name
      }
    }

    template {
      metadata {
        name      = var.project_name
        namespace = kubernetes_namespace.default.metadata[0].name

        labels = {
          run = var.project_name
        }
      }

      spec {
        container {
          image = "gcr.io/${var.project_name}/ehallmarksolutions:latest"
          name = "main"

          env_from {
            config_map_ref {
              name = kubernetes_config_map.site.metadata[0].name
            }
          }

          resources {
            requests {
              cpu = 0.3
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}