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
            name  = "DATABASE_URL"
            value = "mysql+pymysql://root:${random_password.mysql_root_password.result}@mysqldb:3306/myapp_db"
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

resource "kubernetes_ingress" "app_ingress" {
  metadata {
    name      = "app-ingress"
    namespace = "default"
  }

  spec {
    rule {
      host = "comforte.johnydev.com"

      http {
        path {
          backend {
            service_name = kubernetes_service.app_service.metadata.0.name
            service_port = 8080
          }
        }
      }
    }
  }
}