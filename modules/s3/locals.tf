locals {
  bucket_name = "${var.project_name}-${var.env}-images-${random_id.bucket_suffix.hex}"
}
