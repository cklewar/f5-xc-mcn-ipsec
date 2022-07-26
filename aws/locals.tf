locals {
  cluster_name            = format("%s-%s", var.project_prefix, var.project_suffix)
  deployment              = format("%s-%s", var.project_prefix, var.project_suffix)
  master_count            = length(var.cluster_members)
  create_eks_vpc          = var.eks_fabric_address_pool != "" ? 1 : 0
  eks_fabric_address_pool = var.eks_fabric_address_pool != "" ? var.eks_fabric_address_pool : var.fabric_address_pool
  input_peering_vpc_id    = var.fabric_peering_network_id != "" ? true : false
  tunnel_interface_name   = format("%s-tunnel-interface-%s", var.project_prefix, var.project_suffix)
  tunnel_name             = format("%s-tunnel-%s", var.project_prefix, var.project_suffix)
  cluster_labels          = var.fleet_label != "" ? { "ves.io/fleet" = var.fleet_label } : {}
  tunnel_virtual_network  = format("%s-vn-%s", var.project_prefix, var.project_suffix)
  global_vn_name          = format("dt-poc-global-vn-%s", var.project_suffix)
  key_name                = format("%s-key-%s", var.project_prefix, var.project_suffix)
  eks_fabric_subnets      = [
    cidrsubnet(local.eks_fabric_address_pool, 2, 1),
    cidrsubnet(local.eks_fabric_address_pool, 2, 2),
  ]

  common_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    "deployment"                                  = format("%s-%s", var.project_prefix, var.project_suffix)
    "iam_owner"                                   = var.iam_owner
  }
}