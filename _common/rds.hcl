terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/rds"
}

dependency "vpc" {
  config_path = "../../vpc"

  mock_outputs = {
    compute_subnet_ids = ["vpc-mock-id-1", "vpc-mock-id-2", "vpc-mock-id-3"]
    vpc_id             = "vpc-id-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

dependency "dns" {
  config_path = "../../dns"

  mock_outputs = {
    zone_id = "zone-id-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

inputs = {
  project_name       = "bw-bm"
  app2               = "buried-marks"
  vpc_id             = dependency.vpc.outputs.vpc_id
  ver_eso            = "2.2.0"
  db_instance_class  = "db.t3.micro"
  compute_subnet_ids = dependency.vpc.outputs.compute_subnet_ids
  zone_id            = dependency.dns.outputs.zone_id
}
