resource "random_password" "mysql_root_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "kubernetes_secret" "mysql_root_password" {
  metadata {
    name = "mysql-root-password"
  }

  data = {
    MYSQL_ROOT_PASSWORD = base64encode(random_password.mysql_root_password.result)
  }

  depends_on = [random_password.mysql_root_password]
}

resource "kubernetes_config_map" "db_init_script" {
  metadata {
    name = "db-init-script"
  }

  data = {
    "init.sql" = file("${path.module}/init.sql")
  }
}

resource "helm_release" "mysql" {
  name       = "mysqldb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mysql"
  version    = "9.7.2"
  namespace  = "default"

  set {
    name  = "auth.rootPassword"
    value = random_password.mysql_root_password.result
  }

  set {
    name  = "initdbScriptsConfigMap"
    value = kubernetes_config_map.db_init_script.metadata.0.name
  }

  set {
    name  = "primary.persistence.enabled"
    value = "true"
  }
}
