locals {
  deployment             = format("%s-%s", var.project_prefix, var.project_suffix)
  tunnel_name            = format("%s-tunnel-%s", var.project_prefix, var.project_suffix)
  cluster_labels         = var.fleet_label != "" ? { "ves.io/fleet" = var.fleet_label } : {}
  tunnel_interface_name  = format("%s-tunnel-interface-%s", var.project_prefix, var.project_suffix)
  tunnel_virtual_network = format("%s-vn-%s", var.project_prefix, var.project_suffix)
  global_vn_name         = format("dt-poc-global-vn-%s", var.project_suffix)
}