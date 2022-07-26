resource "volterra_token" "site" {
  name      = local.deployment
  namespace = "system"
}

module "ce_network" {
  source               = "../modules/k8s-ce-network-2nic-gcp"
  name                 = local.deployment
  region               = var.region
  zone                 = var.zone
  fabric_subnet_public = var.fabric_subnet_public
  fabric_subnet_inside = var.fabric_subnet_inside
}

module "ce_config" {
  source                      = "../modules/k8s-own-config-gcp"
  gateway_type                = var.gateway_type
  public_name                 = var.public_name
  cluster_type                = var.cluster_type
  name                        = local.deployment
  volterra_token              = volterra_token.site.id
  cluster_latitude            = var.cluster_latitude
  cluster_longitude           = var.cluster_longitude
  maurice_endpoint            = var.maurice_endpoint
  maurice_mtls_endpoint       = var.maurice_mtls_endpoint
  machine_public_key          = var.machine_public_key
  certified_hardware_endpoint = var.certified_hardware_endpoint
  cluster_labels              = local.cluster_labels
}

module "ce_master" {
  source             = "../modules/k8s-ce-master-2nic-gcp"
  name               = local.deployment
  machine_public_key = var.machine_public_key
  machine_type       = var.machine_type
  image              = var.image
  machine_disk_size  = var.machine_disk_size
  sli_subnetwork     = module.ce_network.sli_subnetwork
  slo_subnetwork     = module.ce_network.slo_subnetwork
  user_data          = module.ce_config.user_data
}

/*module "site_status_check" {
  depends_on = [module.ce_master]
  source     = "../modules/status/site"
  api_token  = var.api_token
  api_url    = var.api_url
  namespace  = var.namespace
  site_name  = var.deployment
  tenant     = var.tenant
}*/

module "site_update" {
  depends_on             = [module.ce_master.google_compute_instance_id]
  source                 = "../modules/site/update"
  tenant                 = var.tenant
  namespace              = var.namespace
  api_p12_file           = var.api_p12_file
  api_token              = var.api_token
  api_url                = var.api_url
  global_virtual_network = local.global_vn_name
  site_name              = format("%s-%s", var.project_prefix, var.project_suffix)
  cluster_labels         = local.cluster_labels
}

module "tunnel" {
  source            = "../modules/tunnel"
  tenant            = var.tenant
  namespace         = var.namespace
  api_p12_file      = var.api_p12_file
  api_token         = var.api_token
  api_url           = var.api_url
  tunnel_name       = local.tunnel_name
  remote_ip_address = var.tunnel_remote_ip_address
  clear_secret      = var.tunnel_clear_secret
}

module "interface" {
  depends_on          = [module.tunnel]
  source              = "../modules/interface"
  tenant              = var.tenant
  namespace           = var.namespace
  api_p12_file        = var.api_p12_file
  api_token           = var.api_token
  api_url             = var.api_url
  interface_name      = local.tunnel_interface_name
  interface_type      = "tunnel_interface"
  interface_static_ip = var.tunnel_interface_static_ip
  node_name           = local.deployment
  tunnel_name         = local.tunnel_name
}

module "tunnel_virtual_network" {
  depends_on         = [module.interface]
  source             = "../modules/virtual-network"
  name               = local.tunnel_virtual_network
  namespace          = var.namespace
  site_local_network = true
  tenant             = var.tenant
  tunnel_interface   = local.tunnel_interface_name
  ip_prefixes        = var.tunnel_virtual_network_ip_prefixes
}

module "fleet" {
  depends_on              = [module.interface]
  source                  = "../modules/fleet"
  fleet_name              = format("%s-fleet-%s", var.project_prefix, var.project_suffix)
  fleet_label             = var.fleet_label
  outside_virtual_network = [local.tunnel_virtual_network]
  inside_virtual_network  = var.inside_virtual_network
  networks_interface_list = [format(local.tunnel_interface_name)]
  namespace               = var.namespace
  tenant                  = var.tenant
  api_url                 = var.api_url
  api_p12_file            = var.api_p12_file
}

module "bgp" {
  depends_on              = [module.interface]
  source                  = "../modules/bgp"
  f5xc_namespace          = var.namespace
  f5xc_tenant             = var.tenant
  f5xc_api_url            = var.api_url
  f5xc_api_p12_file       = var.api_p12_file
  f5xc_bgp_asn            = var.bgp_local_asn
  f5xc_bgp_description    = ""
  f5xc_bgp_interface_name = local.tunnel_interface_name
  f5xc_bgp_name           = format("%s-bgp-%s", var.project_prefix, var.project_suffix)
  f5xc_bgp_peer_asn       = var.bgp_peer_asn
  f5xc_bgp_peer_name      = format("%s-peer-%s", var.project_prefix, var.project_suffix)
  f5xc_bgp_peer_address   = var.bgp_peer_address
  f5xc_site_name          = local.deployment
}