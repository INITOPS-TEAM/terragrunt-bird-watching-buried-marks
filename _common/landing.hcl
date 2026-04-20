terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/landing"
}

dependency "dns" {
  config_path = "../dns"

  mock_outputs = {
    zone_id = "zone-id-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_config  = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env         = local.env_config.locals.env
}

inputs = {
  project_name = "bw-bm"
  zone_id      = dependency.dns.outputs.zone_id
}

# root terragrunt.hcl

generate "aws" {
  path      = "aws_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
# Secondary provider for us-east-1 (needed for CloudFront, ACM, etc.)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
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
