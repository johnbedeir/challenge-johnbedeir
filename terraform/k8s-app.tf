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
          image = "702551696126.dkr.ecr.eu-central-1.amazonaws.com/comforte-img:latest"

          env {
            name  = "FLASK_ENV"
            value = "production"
          }

          env {
            name  = "MYSQL_PASSWORD"
            value = base64decode(kubernetes_secret.mysql_root_password.data["MYSQL_ROOT_PASSWORD"])
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
          path      = "/"
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



