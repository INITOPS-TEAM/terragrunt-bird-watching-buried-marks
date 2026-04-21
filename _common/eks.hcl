terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/eks"
}

dependency "vpc" {
  config_path = "../../vpc"

  mock_outputs = {
    compute_subnet_ids = ["vpc-mock-id-1", "vpc-mock-id-2", "vpc-mock-id-3"]
    vpc_id             = "vpc-id-mock"
    eks_subnet_ids     = ["eks-subnet-mock-id-1", "eks-subnet-mock-id-2", "eks-subnet-mock-id-3"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

dependency "jenkins" {
  config_path = "../../jenkins"

  mock_outputs = {
    jenkins_role_arn = "arn:aws:iam::012345678900:role/mock-jenkins-role"
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

dependency "rds" {
  config_path = "../rds"

  mock_outputs = {
    host_postgres_rds    = "host-postgres-rds-mock"
    host_mariadb_rds     = "host-mariadb-rds-mock"
    rds_auth_resource_id = "rds-auth-resource-id-mock"
    rds_map_resource_id  = "rds-map-resource-id-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
}

inputs = {
  node_subnets         = dependency.vpc.outputs.compute_subnet_ids
  vpc_id               = dependency.vpc.outputs.vpc_id
  eks_subnets          = dependency.vpc.outputs.eks_subnet_ids
  kubernetes_version   = "1.35"
  app2                 = "buried-marks"
  ver_eso              = "2.2.0"
  zone_id              = dependency.dns.outputs.zone_id
  jenkins_role_arn     = dependency.jenkins.outputs.jenkins_role_arn
  host_postgres_rds    = dependency.rds.outputs.host_postgres_rds
  host_mariadb_rds     = dependency.rds.outputs.host_mariadb_rds
  rds_auth_resource_id = dependency.rds.outputs.rds_auth_resource_id
  rds_map_resource_id  = dependency.rds.outputs.rds_map_resource_id
}

generate "kubernetes_provider" {
  path      = "kubernetes_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    provider "kubernetes" {
    }
  EOF
}

generate "helm_provider" {
  path      = "helm_provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    provider "helm" {
    }
  EOF
}
