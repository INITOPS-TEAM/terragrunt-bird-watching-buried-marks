resource "kubernetes_namespace_v1" "buried_marks" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_namespace_v1" "envoy_gw_api" {
  metadata {
    name = "envoy-gateway-system"
  }
}

resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "envoy_gw_api" {
  name       = "envoy-gw"
  namespace  = kubernetes_namespace_v1.envoy_gw_api.metadata[0].name
  repository = "oci://docker.io/envoyproxy"
  version    = "1.7.1"
  chart      = "gateway-helm"
}

resource "helm_release" "gateway" {
  name       = "gateway"
  namespace  = kubernetes_namespace_v1.buried_marks.metadata[0].name
  repository = local.repository
  version    = "0.2.0"
  chart      = "buried-marks-helm-gateway"
  depends_on = [helm_release.envoy_gw_api]

  set = [
    {
      name  = "aws.certificateArn"
      value = aws_acm_certificate_validation.marks.certificate_arn
    }
  ]
}

resource "helm_release" "authentication_microservice" {
  name       = "auth-service"
  namespace  = kubernetes_namespace_v1.buried_marks.metadata[0].name
  repository = local.repository
  version    = "0.1.2"
  chart      = "buried-marks-helm-authentication-microservice"
  depends_on = [
    helm_release.gateway,
    helm_release.eso
  ]
  set = [
    {
      name  = "fullnameOverride"
      value = "authentication-microservice"
    },
    {
      name  = "image.repository"
      value = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/buried-marks-authentication-microservice"
    },
    {
      name  = "db.host"
      value = var.host_postgres_rds
    },
    {
      name  = "db.port"
      value = "5432"
    },
  ]
}

resource "helm_release" "map_microservice" {
  name       = "map-service"
  namespace  = kubernetes_namespace_v1.buried_marks.metadata[0].name
  repository = local.repository
  version    = "0.1.2"
  chart      = "buried-marks-helm-map-microservice"
  depends_on = [
    helm_release.gateway,
    helm_release.eso
  ]
  set = [
    {
      name  = "fullnameOverride"
      value = "map-microservice"
      # value = "map-service" # Required naming for K8s SA to Consul service binding
    },
    {
      name  = "httpRoute.rules[0].matches[0].path.value"
      value = "/map/api/"
    },
    {
      name  = "httpRoute.rules[0].matches[0].path.type"
      value = "PathPrefix"
    },
    {
      name  = "httpRoute.rules[0].filters[0].type"
      value = "URLRewrite"
    },
    {
      name  = "httpRoute.rules[0].filters[0].urlRewrite.path.replacePrefixMatch"
      value = "/api/"
    },
    {
      name  = "httpRoute.rules[0].filters[0].urlRewrite.path.type"
      value = "ReplacePrefixMatch"
    },
    {
      name  = "image.repository"
      value = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/buried-marks-map-microservice"
    },
    {
      name  = "db.host"
      value = var.host_mariadb_rds
    },
    {
      name  = "db.port"
      value = "3306"
    },
    {
      name  = "s3.bucketName"
      value = data.aws_s3_bucket.buried_marks_media.id
    },
  ]
}

resource "helm_release" "mail_microservice" {
  name       = "mail-service"
  namespace  = kubernetes_namespace_v1.buried_marks.metadata[0].name
  repository = local.repository
  version    = "0.1.0"
  chart      = "buried-marks-helm-mail-microservice"
  depends_on = [
    helm_release.gateway,
    helm_release.eso
  ]
  set = [
    {
      name  = "fullnameOverride"
      value = "mail-microservice"
    },
    {
      name  = "image.repository"
      value = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/buried-marks-mail-microservice"
    }
  ]
}

resource "helm_release" "voting_microservice" {
  name       = "voting-service"
  namespace  = kubernetes_namespace_v1.buried_marks.metadata[0].name
  repository = local.repository
  version    = "0.1.1"
  chart      = "buried-marks-helm-voting-microservice"
  depends_on = [
    helm_release.gateway,
    helm_release.eso
  ]
  set = [
    {
      name  = "fullnameOverride"
      value = "voting-microservice"
    },
    {
      name  = "image.repository"
      value = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/buried-marks-voting-microservice"
    },
    {
      name  = "db.host"
      value = var.host_postgres_rds
    },
    {
      name  = "db.port"
      value = "5432"
    },
  ]
}

resource "helm_release" "login_front" {
  name       = "login-front"
  namespace  = kubernetes_namespace_v1.buried_marks.metadata[0].name
  repository = local.repository
  version    = "0.1.1"
  chart      = "buried-marks-helm-login-front"
  depends_on = [
    helm_release.authentication_microservice
  ]
  set = [
    {
      name  = "fullnameOverride"
      value = "login-front"
    },
    {
      name  = "image.repository"
      value = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/buried-marks-login-front"
    }
  ]
}

resource "helm_release" "map_front" {
  name       = "map-front"
  namespace  = kubernetes_namespace_v1.buried_marks.metadata[0].name
  repository = local.repository
  version    = "0.1.1"
  chart      = "buried-marks-helm-map-front"
  depends_on = [
    helm_release.map_microservice
  ]
  set = [
    {
      name  = "fullnameOverride"
      value = "map-front"
    },
    {
      name  = "image.repository"
      value = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/buried-marks-map-front"
    }
  ]
}

resource "helm_release" "admin_front" {
  name       = "admin-front"
  namespace  = kubernetes_namespace_v1.buried_marks.metadata[0].name
  repository = local.repository
  version    = "0.1.1"
  chart      = "buried-marks-helm-admin-front"
  depends_on = [
    helm_release.mail_microservice
  ]
  set = [
    {
      name  = "fullnameOverride"
      value = "admin-front"
    },
    {
      name  = "image.repository"
      value = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/buried-marks-admin-front"
    }
  ]
}

resource "helm_release" "voting_front" {
  name       = "voting-front"
  namespace  = kubernetes_namespace_v1.buried_marks.metadata[0].name
  repository = local.repository
  version    = "0.1.1"
  chart      = "buried-marks-helm-voting-front"
  depends_on = [
    helm_release.voting_microservice
  ]
  set = [
    {
      name  = "fullnameOverride"
      value = "voting-front"
    },
    {
      name  = "image.repository"
      value = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/buried-marks-voting-front"
    }
  ]
}

resource "helm_release" "monitoring" {
  name       = "monitoring"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  repository = local.repository
  version    = "0.1.0"
  chart      = "buried-marks-helm-monitoring"
  depends_on = [
    helm_release.eso
  ]

  set = [
    {
      name  = "fullnameOverride"
      value = "monitoring"
    }
  ]
}

resource "helm_release" "mcp" {
  name       = "mcp"
  namespace  = kubernetes_namespace_v1.buried_marks.metadata[0].name
  repository = local.repository
  version    = "0.1.0"
  chart      = "buried-marks-helm-mcp"
  depends_on = [
    helm_release.gateway,
    helm_release.eso
  ]
  set = [
    {
      name  = "fullnameOverride"
      value = "mcp-service"
    },
    {
      name  = "image.repository"
      value = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/buried-marks-mcp"
    }
  ]
}
