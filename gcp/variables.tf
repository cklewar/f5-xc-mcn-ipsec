variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
}

variable "api_p12_file" {
  type = string
}

variable "api_url" {
  type = string
}

variable "api_ca_cert" {
  type    = string
  default = ""
}

variable "api_cert" {
  type    = string
  default = ""
}

variable "api_key" {
  type    = string
  default = ""
}

variable "api_token" {
  type    = string
  default = ""
}

variable "tenant" {
  type = string
}

variable "namespace" {
  type = string
}

variable "fleet_label" {
  type = string
}

variable "gcp_credentials_file_path" {
  type = string
}

variable "gcp_project_name" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "image" {
  type    = string
  default = "vesio-dev-cz/centos7-atomic-202007210749-multi"
}

variable "machine_type" {
  type    = string
  default = "n1-standard-4"
}

variable "machine_disk_size" {
  type    = string
  default = "40"
}

# ce_network
variable "fabric_subnet_public" {
  type = string
}

variable "fabric_subnet_inside" {
  type = string
}

# ce_config
variable "cluster_type" {
  type    = string
  default = "ce"
}

variable "maurice_endpoint" {
  type    = string
  default = "https://register.ves.volterra.io"
}

variable "maurice_mtls_endpoint" {
  type    = string
  default = "https://register-tls.ves.volterra.io"
}

variable "gateway_type" {
  type    = string
  default = "ingress_egress_gateway"
}

variable "cluster_latitude" {
  type = string
}

variable "cluster_longitude" {
  type = string
}

variable "cluster_labels" {
  type    = map(string)
  default = {}
}

variable "public_name" {
  type    = string
  default = "vip"
}

variable "certified_hardware_endpoint" {
  type    = string
  default = "https://vesio.blob.core.windows.net/releases/certified-hardware/gcp.yml"
}

variable "machine_public_key" {
  type = string
}

variable "tunnel_interface_static_ip" {
  type = string
}

variable "tunnel_clear_secret" {
  type    = string
  default = ""
}

variable "tunnel_remote_ip_address" {
  type    = string
  default = ""
}

variable "inside_virtual_network" {
  type    = list(string)
  default = []
}

variable "tunnel_virtual_network_ip_prefixes" {
  type = list(string)
}

variable "bgp_local_asn" {
  type = number
}

variable "bgp_peer_asn" {
  type = number
}

variable "bgp_peer_address" {
  type = string
}