terraform {
  source = "${dirname(find_in_parent_folders("root.hcl"))}/modules/region-generic"
}

inputs = {
  project_name = "bw-bm"
}
