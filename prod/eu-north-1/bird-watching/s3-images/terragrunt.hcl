include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "common" {
  path           = "${dirname(find_in_parent_folders("root.hcl"))}/_common/s3.hcl"
  merge_strategy = "deep"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  project_name      = "bird"
  env               = local.env_vars.locals.env
  versioning_status = "Suspended"
}
