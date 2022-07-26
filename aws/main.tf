resource "volterra_token" "site" {
  name      = local.deployment
  namespace = var.namespace
}

resource "aws_key_pair" "volterra_key" {
  key_name   = local.key_name
  public_key = var.machine_public_key
}

resource "null_resource" "delay_vpc_creation" {
  provisioner "local-exec" {
    command = "sleep 1"
  }

  triggers = {
    "before" = aws_key_pair.volterra_key.id
  }
}

resource "aws_vpc" "volterra_vpc" {
  cidr_block           = var.fabric_address_pool
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags                 = local.common_tags
  depends_on           = [null_resource.delay_vpc_creation]
}

module "ce_network" {
  source                = "../modules/k8s-ce-network-2nic-aws"
  deployment            = local.deployment
  region                = var.region
  dns_zone_suffix       = var.dns_zone_suffix
  fabric_address_pool   = var.fabric_address_pool
  fabric_subnet_private = var.fabric_subnet_private
  fabric_subnet_inside  = var.fabric_subnet_inside
  vpc_id                = aws_vpc.volterra_vpc.id
  ce_inside_intf_id     = element(module.ce_master.inside_intf_ids, 0)
  iam_owner             = var.iam_owner
}

module "ce_config" {
  source                        = "../modules/k8s-own-config-any"
  template_suffix               = "single-2nic-aws"
  deployment                    = local.deployment
  container_images              = var.container_images
  public_address                = ""
  public_name                   = "vip"
  vp_manager_version            = var.vp_manager_version
  vp_manager_type               = var.vp_manager_type
  vp_manager_skip_stages        = var.vp_manager_skip_stages
  vp_manager_master_skip_stages = var.vp_manager_master_skip_stages
  pikachu_endpoint              = var.pikachu_endpoint
  maurice_endpoint              = var.maurice_endpoint
  maurice_mtls_endpoint         = var.maurice_mtls_endpoint
  dns_zone_name                 = ""
  sre_dns_service_ip            = var.sre_dns_service_ip
  cluster_members               = ["master-0"]
  cluster_name                  = local.cluster_name
  private_default_gw            = var.private_default_gw
  private_vn_prefix             = var.private_vn_prefix
  cluster_token                 = volterra_token.site.id
  customer_route                = var.customer_route
  cluster_latitude              = var.cluster_latitude
  cluster_longitude             = var.cluster_longitude
  cluster_workload              = var.cluster_workload
  cluster_labels                = local.cluster_labels
  master_count                  = local.master_count
  ves_env                       = var.ves_env
  user_name                     = var.user_name
  user_password                 = var.user_password
  mask_hugepages_service        = "false"
  nic_fabric                    = var.nic_private
  nic_public                    = var.nic_inside
  certified_hardware_endpoint   = var.certified_hardware_endpoint
}

module "ce_master" {
  source                    = "../modules/k8s-ce-master-2nic-aws"
  deployment                = local.deployment
  region                    = var.region
  machine_image             = var.machine_image[var.region]
  machine_count             = "1"
  machine_names             = ["master-0"]
  machine_type              = var.machine_type
  machine_public_key        = var.machine_public_key
  key_name                  = local.key_name
  machine_config            = module.ce_config.cloud_config_master_primary
  subnet_private_id         = module.ce_network.subnet_private_id
  subnet_inside_id          = module.ce_network.subnet_inside_id
  security_group_private_id = module.ce_network.security_group_private_id
  target_group_arn          = module.ce_network.target_group_arn
  machine_disk_size         = var.machine_disk_size
  enable_auto_registration  = var.enable_auto_registration
  disable_public_ip         = var.ce_disable_public_ip
  iam_instance_profile_name = module.ce_network.iam_instance_profile_name
  iam_owner                 = var.iam_owner
}

data "aws_instances" "ces" {
  depends_on           = [module.ce_master.aws_instance_id]
  instance_state_names = ["running"]

  filter {
    name   = "tag:deployment"
    values = [local.deployment]
  }

  filter {
    name   = "tag:iam_owner"
    values = [var.iam_owner]
  }

  filter {
    name   = "tag:Name"
    values = ["master-0"]
  }

  filter {
    name   = format("tag:kubernetes.io/cluster/%s", local.cluster_name)
    values = ["owned"]
  }
}

module "ce_pools" {
  source                    = "../modules/k8s-ce-pool-2nic-aws"
  deployment                = local.deployment
  region                    = var.region
  machine_image             = var.machine_image[var.region]
  machine_count             = var.machine_count
  machine_type              = var.machine_type
  machine_public_key        = var.machine_public_key
  key_name                  = local.key_name
  machine_config            = module.ce_config.cloud_config_pool
  subnet_private_id         = module.ce_network.subnet_private_id
  subnet_inside_id          = module.ce_network.subnet_inside_id
  security_group_private_id = module.ce_network.security_group_private_id
  dns_zone_id               = module.ce_network.dns_zone_id
  dns_zone_name             = module.ce_network.dns_zone_name
  maurice_endpoint          = var.maurice_endpoint
  dhcp_id                   = module.ce_network.dhcp_id
  machine_disk_size         = var.machine_disk_size
  iam_owner                 = var.iam_owner
}

module "global_virtual_network" {
  source         = "../modules/virtual-network"
  name           = local.global_vn_name
  tenant         = var.tenant
  namespace      = var.namespace
  global_network = true
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
  depends_on             = [module.ce_master.aws_instance_id]
  source                 = "../modules/site/update"
  tenant                 = var.tenant
  namespace              = var.namespace
  api_p12_file           = var.api_p12_file
  api_token              = var.api_token
  api_url                = var.api_url
  global_virtual_network = local.global_vn_name
  site_name              = local.deployment
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
  node_name           = format("ip-%s", replace(data.aws_instances.ces.private_ips[0], ".", "-"))
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
  networks_interface_list = [local.tunnel_interface_name]
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

output "device_name" {
  value = format("ip-%s", replace(data.aws_instances.ces.private_ips[0], ".", "-"))
}

output "fabric_network" {
  value = module.ce_network.network_cidr
}

output "fabric_subnet_private_id" {
  value = module.ce_network.subnet_private_id
}

output "public_ip_address" {
  value = length(module.ce_master.public_addresses) > 0 ? join(",", module.ce_master.public_addresses) : ""
}

output "private_ip_address" {
  value = length(module.ce_master.addresses) > 0 ? join(",", module.ce_master.addresses) : ""
}

output "inside_ip_address" {
  value = length(module.ce_master.inside_addresses) > 0 ? join(",", module.ce_master.inside_addresses) : ""
}

output "fabric_subnet_private" {
  value = var.fabric_subnet_private
}