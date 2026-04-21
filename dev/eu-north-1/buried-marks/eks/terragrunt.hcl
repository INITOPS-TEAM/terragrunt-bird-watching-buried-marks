include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "common" {
  path           = "${dirname(find_in_parent_folders("root.hcl"))}/_common/eks.hcl"
  merge_strategy = "deep"
}

locals {
  env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

inputs = {
  env            = local.env_vars.locals.env
  cluster_name   = "birdmarks-eks-dev-01"
  desired_size   = 6
  min_size       = 4
  max_size       = 7
  instance_types = ["t3.small"]
  aws_region     = local.region_vars.locals.aws_region
  account_id     = local.region_vars.locals.account_id
  namespace      = "buried-marks"
  domain_name    = "buriedmarks.pp.ua"
}
