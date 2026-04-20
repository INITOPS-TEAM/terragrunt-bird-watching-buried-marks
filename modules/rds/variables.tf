variable "project_name" {
  type = string
}

variable "app2" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "env" {
  type = string
}

variable "ver_eso" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "compute_subnet_ids" {
  type = list(string)
}

variable "compute_subnets" {
  type = map(string)
}

variable "domain_name" {
  description = "base part of domain name"
  type        = string
}

variable "zone_id" {
  description = "Route53 Zone ID passed from the environment level"
  type        = string
}
