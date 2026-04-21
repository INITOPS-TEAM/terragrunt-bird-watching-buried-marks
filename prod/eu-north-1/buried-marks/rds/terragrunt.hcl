include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "common" {
  path           = "${dirname(find_in_parent_folders("root.hcl"))}/_common/rds.hcl"
  merge_strategy = "deep"
}

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

inputs = {
  env         = local.env_vars.locals.env
  domain_name = "birds.pp.ua"
  aws_region  = local.region_vars.locals.aws_region
  compute_subnets = {
    "eu-north-1a" = "10.20.10.0/24"
    "eu-north-1b" = "10.20.20.0/24"
  }
}
