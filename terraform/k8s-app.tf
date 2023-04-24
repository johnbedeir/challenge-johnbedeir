resource "kubernetes_deployment" "app_deployment" {
  metadata {
    name      = "app-deployment"
    namespace = "default"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "app"
      }
    }

    template {
      metadata {
        labels = {
          app = "app"
        }
      }

      spec {
        container {
          name  = "app"
          image = aws_ecr_repository.ecr_repo.name

          env {
            name  = "FLASK_ENV"
            value = "production"
          }

          env {
            name = "MYSQL_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mysql_root_password.metadata.0.name
                key  = "MYSQL_ROOT_PASSWORD"
              }
            }
          }

          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app_service" {
  metadata {
    name      = "app-service"
    namespace = "default"
  }

  spec {
    selector = {
      app = "app"
    }

    port {
      name        = "http"
      port        = 8080
      target_port = 5000
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name      = "app-ingress"
    namespace = "default"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      host = "comforte.johnydev.com"

      http {
        path {
          path      = "/(.*)"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.app_service.metadata[0].name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}



