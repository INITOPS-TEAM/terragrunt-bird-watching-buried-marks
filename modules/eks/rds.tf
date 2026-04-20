resource "aws_iam_policy" "eks_rds" {
  name = "EKS-RDS"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "rds-db:connect"
        ],
        "Resource" : [
          "arn:aws:rds-db:${var.aws_region}:${var.account_id}:dbuser:${var.rds_auth_resource_id}/*",
          "arn:aws:rds-db:${var.aws_region}:${var.account_id}:dbuser:${var.rds_map_resource_id}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_rds" {
  for_each   = toset(local.eks_rds_sa)
  role       = aws_iam_role.eks_rds_service[each.key].name
  policy_arn = aws_iam_policy.eks_rds.arn
}

resource "aws_iam_role" "eks_rds_service" {
  for_each = toset(local.eks_rds_sa)
  name     = "EKS-RDS-service-${each.key}"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowEksAuthToAssumeRoleForPodIdentity",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "pods.eks.amazonaws.com"
        },
        "Action" : [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "eks-pod-identity-agent"
  depends_on   = [aws_eks_node_group.main]
}

resource "aws_eks_pod_identity_association" "eks_rds" {
  for_each        = toset(local.eks_rds_sa)
  cluster_name    = aws_eks_cluster.main.name
  namespace       = kubernetes_namespace_v1.buried_marks.metadata[0].name
  service_account = each.key
  role_arn        = aws_iam_role.eks_rds_service[each.key].arn
}


resource "aws_iam_policy" "buried_marks_media" {
  name = "BuriedMarksS3Policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket"],
        "Resource" : "${data.aws_s3_bucket.buried_marks_media.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "buried_marks_media" {
  role       = aws_iam_role.eks_rds_service["map-service"].name
  policy_arn = aws_iam_policy.buried_marks_media.arn
}
