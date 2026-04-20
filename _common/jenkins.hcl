terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/jenkins"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    compute_subnet_id = "vpc-mock-id"
    vpc_cidr          = "10.20.0.0/16"
    vpc_id            = "vpc-id-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

dependency "region_generic" {
  config_path = "../region-generic"

  mock_outputs = {
    key_name = "key-name-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

inputs = {
  project_name          = "bw-bm"
  key_name              = dependency.region_generic.outputs.key_name
  ami_id                = "ami-080254318c2d8932f"
  instance_type_jenkins = "t3.small"
  compute_subnet_id     = dependency.vpc.outputs.compute_subnet_id
  vpc_cidr              = dependency.vpc.outputs.vpc_cidr
  vpc_id                = dependency.vpc.outputs.vpc_id
}
