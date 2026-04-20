terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/ec2"
}

dependency "vpc" {
  config_path = "../../vpc"

  mock_outputs = {
    compute_subnet_id = "compute-subnet-mock-id"
    public_subnet_id  = "public-subnet-mock-id"
    vpc_cidr          = "10.20.0.0/16"
    vpc_id            = "vpc-id-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

dependency "jenkins" {
  config_path = "../../jenkins"

  mock_outputs = {
    jenkins_sg_id = "jenkins-sg-id-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

dependency "region_generic" {
  config_path = "../../region-generic"

  mock_outputs = {
    key_name = "key-name-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

dependency "iam" {
  config_path = "../iam"

  mock_outputs = {
    app_role_name             = "app-role-name-mock"
    app_instance_profile_name = "app-instance-profile-name-mock"
    ssm_instance_profile_name = "ssm-instance-profile-name-mock"
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
  project_name              = "bw-bm"
  key_name                  = dependency.region_generic.outputs.key_name
  ami_id                    = "ami-080254318c2d8932f"
  instance_type             = "t3.small"
  compute_subnet_id         = dependency.vpc.outputs.compute_subnet_id
  public_subnet_id          = dependency.vpc.outputs.public_subnet_id
  vpc_cidr                  = dependency.vpc.outputs.vpc_cidr
  vpc_id                    = dependency.vpc.outputs.vpc_id
  jenkins_sg_id             = dependency.jenkins.outputs.jenkins_sg_id
  app_instance_count        = 2
  app_role_name             = dependency.iam.outputs.app_role_name
  iam_instance_profile_name = dependency.iam.outputs.app_instance_profile_name
  ssm_instance_profile_name = dependency.iam.outputs.ssm_instance_profile_name
  zone_id                   = dependency.dns.outputs.zone_id
}
