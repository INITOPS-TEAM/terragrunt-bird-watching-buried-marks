terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/s3"
}

inputs = {
  project_name = "bw-bm"
}

generate "random_provider" {
  path      = "random_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    provider "random" {
    }
  EOF
}
