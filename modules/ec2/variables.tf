variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "key_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "compute_subnet_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "jenkins_sg_id" {
  type = string
}

variable "app_instance_count" {
  type = number
}

variable "iam_instance_profile_name" {
  type = string
}

variable "app_role_name" {
  type = string
}

variable "ssm_instance_profile_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "zone_id" {
  description = "Route53 Zone ID passed from the environment level"
  type        = string
}
