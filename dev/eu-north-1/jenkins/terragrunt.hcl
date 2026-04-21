include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "common" {
  path           = "${dirname(find_in_parent_folders("root.hcl"))}/_common/jenkins.hcl"
  merge_strategy = "deep"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  nat_az = "eu-north-1a"
  env    = local.env_vars.locals.env
}
