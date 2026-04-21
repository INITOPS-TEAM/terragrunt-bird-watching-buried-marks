output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "EKS cluster endpoint"
}

output "cluster_ca_certificate" {
  value       = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
  description = "EKS cluster CA certificate"
  sensitive   = true
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.main.arn
  description = "OIDC provider ARN (for IRSA)"
}

output "oidc_provider_url" {
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
  description = "OIDC provider URL"
}

output "cluster_security_group_id" {
  description = "ID of the security group for EKS cluster. Required for allowing access to RDS from EKS."
  value       = aws_security_group.eks_cluster.id
}
