include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "common" {
  path           = "${dirname(find_in_parent_folders("root.hcl"))}/_common/dns.hcl"
  merge_strategy = "deep"
}

inputs = {
  domain_name = "buriedmarkstg.pp.ua"
}
