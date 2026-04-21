terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/vpc"
}

inputs = {
  project_name = "bw-bm"
}
