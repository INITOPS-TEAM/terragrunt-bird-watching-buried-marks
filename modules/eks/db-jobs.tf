resource "kubernetes_job_v1" "postgres_rds_enable_iam" {
  metadata {
    name      = "postgres-rds-enable-iam"
    namespace = kubernetes_namespace_v1.buried_marks.metadata[0].name
  }
  spec {
    ttl_seconds_after_finished = 100
    template {
      metadata {}
      spec {
        container {
          name    = "postgres-rds-enable-iam"
          image   = "alpine/psql:18.3"
          command = ["sh", "-c", "psql postgresql://${local.auth_secret["DB_USER"]}:${local.auth_secret["DB_PASSWORD"]}@${var.host_postgres_rds}/${local.auth_secret["DB_NAME"]}?sslmode=require -c 'GRANT rds_iam TO ${local.auth_secret["DB_USER"]};'; PSQL_EXIT_CODE=$?; if [ $PSQL_EXIT_CODE -eq '0' ]; then echo 'IAM authentication check is successfully completed'; exit 0; elif [ $PSQL_EXIT_CODE -eq '2' ]; then echo 'IAM authentication is already enabled for ${local.auth_secret["DB_USER"]} OR specified long-living password is incorrect'; exit 0; fi; exit 1"]
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  wait_for_completion = true
  timeouts {
    create = "2m"
    update = "2m"
  }
}

resource "kubernetes_job_v1" "mariadb_rds_enable_iam" {
  metadata {
    name      = "mariadb-rds-enable-iam"
    namespace = kubernetes_namespace_v1.buried_marks.metadata[0].name
  }
  spec {
    ttl_seconds_after_finished = 100
    template {
      metadata {}
      spec {
        container {
          name  = "mariadb-rds-enable-iam"
          image = "alpine/mariadb:11.4.9"
          # command = ["sh", "-c", "sleep inf"]
          command = ["sh", "-c", "mariadb -h ${var.host_mariadb_rds} -P ${local.map_secret["DATABASE_PORT"]} -u ${local.map_secret["MARIADB_USER"]} --password=${local.map_secret["MARIADB_PASSWORD"]} -e 'ALTER USER ${local.map_secret["MARIADB_USER"]} IDENTIFIED WITH AWSAuthenticationPlugin AS \"RDS\";'; MARIADB_EXIT_CODE=$?; if [ $MARIADB_EXIT_CODE -eq '0' ]; then echo '!!! IAM authentication is successfully enabled !!!'; exit 0; elif [ $MARIADB_EXIT_CODE -eq '1' ]; then echo 'IAM authentication is already enabled for ${local.map_secret["MARIADB_USER"]} OR specified long-living password is incorrect'; exit 0; fi; exit 1"]
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  wait_for_completion = true
  timeouts {
    create = "2m"
    update = "2m"
  }
}
