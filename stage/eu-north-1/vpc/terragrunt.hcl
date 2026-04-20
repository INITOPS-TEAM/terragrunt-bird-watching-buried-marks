include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "common" {
  path           = "${dirname(find_in_parent_folders("root.hcl"))}/_common/vpc.hcl"
  merge_strategy = "deep"
}

locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  env          = local.env_vars.locals.env
  vpc_cidr     = "10.20.0.0/16"
  cluster_name = "birdmarks-eks-stage"
  nat_az       = "eu-north-1a"
  public_subnets = {
    "eu-north-1a" = "10.20.1.0/24"
    "eu-north-1b" = "10.20.2.0/24"
  }
  compute_subnets = {
    "eu-north-1a" = "10.20.10.0/24"
    "eu-north-1b" = "10.20.20.0/24"
  }
  eks_subnets = {
    "eu-north-1a" = "10.20.128.0/20"
    "eu-north-1b" = "10.20.144.0/20"
  }
}
