# OIDC Provider for IRSA
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

data "aws_secretsmanager_secret_version" "auth" {
  secret_id = "buried-marks/auth-service"
}

data "aws_secretsmanager_secret_version" "map" {
  secret_id = "buried-marks/map-service"
}

data "aws_s3_bucket" "buried_marks_media" {
  bucket = local.buried_marks_media[var.env]
}
