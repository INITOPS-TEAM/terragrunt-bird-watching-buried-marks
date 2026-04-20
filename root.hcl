locals {
  env_config    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  region_config = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  env    = local.env_config.locals.env
  region = local.region_config.locals.aws_region
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 6.0"
        }
      }
    }
    provider "aws" {
      region = "${local.region}"

      default_tags {
        tags = {
          Environment = "${local.env}"
          ManagedBy = "Terragrunt"
          Project = "bw-bm"
        }
      }
    }
  EOF
}

remote_state {
  backend = "s3"
  config = {
    encrypt      = true
    bucket       = "buried-marks-${local.env}"
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()
  }
}
