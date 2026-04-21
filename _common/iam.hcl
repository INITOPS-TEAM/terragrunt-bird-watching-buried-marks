terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/iam"
}

inputs = {
  project_name = "bw-bm"
}
