variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "versioning_status" {
  type        = string
  default     = "Suspended"
  description = "Enabled for DB or Suspended for images"
}

variable "iam_instance_profile_name" {
  type    = string
  default = null
}
