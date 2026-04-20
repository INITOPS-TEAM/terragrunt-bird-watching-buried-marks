variable "env" {
  type = string
}

variable "app2" {
  type = string
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "eks_subnets" {
  type        = list(string)
  description = "List of subnet IDs for EKS control plane"
}

variable "node_subnets" {
  type        = list(string)
  description = "List of subnet IDs for worker nodes"
}

variable "node_group_name" {
  type        = string
  default     = "primary"
  description = "Node group name"
}

variable "desired_size" {
  type        = number
  default     = 4
  description = "Desired number of nodes"
}

variable "min_size" {
  type        = number
  default     = 1
  description = "Minimum nodes"
}

variable "max_size" {
  type        = number
  default     = 3
  description = "Maximum nodes"
}

variable "instance_types" {
  type        = list(string)
  default     = ["t3.small"]
  description = "EC2 instance types"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.35"
  description = "Kubernetes version"
}

variable "aws_region" {
  type = string
}

variable "account_id" {
  type = string
}

variable "namespace" {
  type = string
}

variable "ver_eso" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "jenkins_role_arn" {
  description = "ARN of the Jenkins IAM Role for EKS access"
  type        = string
}

variable "host_postgres_rds" {
  description = "auth RDS endpoint"
  type        = string
}

variable "host_mariadb_rds" {
  description = "map RDS endpoint"
  type        = string
}

variable "rds_auth_resource_id" {
  type = string
}

variable "rds_map_resource_id" {
  type = string
}
