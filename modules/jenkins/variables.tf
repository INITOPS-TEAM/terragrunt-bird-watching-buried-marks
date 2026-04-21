variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type_jenkins" {
  type = string
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "compute_subnet_id" {
  description = "Private subnet ID for Jenkins"
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "nat_az" {
  type = string
}
