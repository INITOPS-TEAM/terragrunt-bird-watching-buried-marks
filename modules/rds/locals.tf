data "aws_secretsmanager_secret_version" "auth" {
  secret_id = "buried-marks/auth-service"
}

data "aws_secretsmanager_secret_version" "map" {
  secret_id = "buried-marks/map-service"
}

data "aws_secretsmanager_secret_version" "voting" {
  secret_id = "buried-marks/voting-service"
}

locals {
  auth_secret   = jsondecode(data.aws_secretsmanager_secret_version.auth.secret_string)
  map_secret    = jsondecode(data.aws_secretsmanager_secret_version.map.secret_string)
  voting_secret = jsondecode(data.aws_secretsmanager_secret_version.voting.secret_string)
  mar_eng_v     = "11.8"
  postg_eng_v   = "18.3"

  db_defaults = {
    instance_class      = var.db_instance_class
    allocated_storage   = 10
    skip_final_snapshot = true
  }
  common_tags = {
    Environment = var.env
    Project     = var.project_name
    App         = var.app2
    ManagedBy   = "Terraform"
  }
}
