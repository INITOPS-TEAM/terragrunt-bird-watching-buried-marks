# resource "helm_release" "ebs_csi_driver" {
#   name       = "aws-ebs-csi-driver"
#   repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
#   chart      = "aws-ebs-csi-driver"
#   namespace  = "kube-system"
#   version    = "2.57.1"

#   values = [
#     yamlencode({
#       controller = {
#         serviceAccount = {
#           create = true
#           name   = "ebs-csi-controller-sa"
#           annotations = {
#             "eks.amazonaws.com/role-arn" = aws_iam_role.ebs_csi_controller_role.arn
#           }
#         }
#       }
#     })
#   ]

#   depends_on = [
#     aws_eks_cluster.main
#   ]
# }

# # IAM Role for EBS CSI Controller
# resource "aws_iam_role" "ebs_csi_controller_role" {
#   name = "${var.cluster_name}-ebs-csi-controller-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
#         }
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Condition = {
#           StringEquals = {
#             "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
#             "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
#           }
#         }
#       }
#     ]
#   })
# }

# # Attach EBS CSI Driver Policy
# resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#   role       = aws_iam_role.ebs_csi_controller_role.name
# }

# # StorageClass for Dynamic Volume Provisioning
# resource "kubernetes_storage_class_v1" "ebs_gp2" {
#   metadata {
#     name = "gp2-ebs"
#     annotations = {
#       "storageclass.kubernetes.io/is-default-class" = "true"
#     }
#   }

#   storage_provisioner    = "ebs.csi.aws.com"
#   reclaim_policy         = "Delete"
#   volume_binding_mode    = "WaitForFirstConsumer"
#   allow_volume_expansion = true

#   parameters = {
#     type      = "gp2"
#     encrypted = "true"
#   }

#   depends_on = [helm_release.ebs_csi_driver]
# }

# EBS CSI Driver Add-on for persistent volumes (needed for Consul storage)
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.main.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi.arn

  tags = {
    Name = "${var.cluster_name}-${var.env}-ebs-csi"
  }

  depends_on = [aws_eks_node_group.main]
}

# IAM Role for EBS CSI Driver
resource "aws_iam_role" "ebs_csi" {
  name = "${var.cluster_name}-${var.env}-ebs-csi-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.main.arn
        }
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.main.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = {
    Name = "${var.cluster_name}-${var.env}-ebs-csi-role"
  }
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi.name
}

resource "kubernetes_storage_class_v1" "ebs_gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
  parameters = {
    type = "gp3"
  }
  depends_on = [aws_eks_addon.ebs_csi]
}
