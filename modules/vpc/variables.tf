variable "project_name" {
  type = string
}

variable "env" {
  type        = string
  description = "The environment name (dev, stage, prod)"
}

variable "vpc_cidr" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "nat_az" {
  type = string
}

variable "public_subnets" {
  type = map(string)
}

variable "compute_subnets" {
  type = map(string)
}

variable "eks_subnets" {
  type = map(string)
}
