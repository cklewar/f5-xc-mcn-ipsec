variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}

variable "session_token" {
  type    = string
  default = ""
}

variable "region" {
  type = string
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

variable "machine_image" {
  type    = map(string)
  default = {
    ca-central-1   = "ami-077bb9c847c6d9ef7"
    af-south-1     = "ami-05d60209ebad1f70c"
    ap-east-1      = "ami-0b9cab48b17de8415"
    ap-northeast-2 = "ami-0c548676e9a27ce83"
    ap-southeast-2 = "ami-00c8b3cc35d782bf7"
    ap-south-1     = "ami-01a1a13f752b02d59"
    ap-northeast-1 = "ami-03297d670703981c9"
    ap-southeast-1 = "ami-05b28eabaf624a6bf"
    eu-central-1   = "ami-0e99cef1d8e41d9e1"
    eu-west-1      = "ami-09cf2c94b0d2ca355"
    eu-west-3      = "ami-03175b50db858bc6b"
    eu-south-1     = "ami-07386e2285d5dff8a"
    eu-north-1     = "ami-048577c3054929b99"
    eu-west-2      = "ami-094389688d488aeaa"
    me-south-1     = "ami-031a36a354ddadff7"
    sa-east-1      = "ami-0c5498aa41af80bfd"
    us-east-1      = "ami-0fa4728603d6f753c"
    us-east-2      = "ami-0eadac5d175627120"
    us-west-1      = "ami-0da9d480ee4009846"
    us-west-2      = "ami-0b0adddceaf57d93d"
  }
}

variable "machine_type" {
  type    = string
  default = "t3.xlarge"
}

variable "machine_count" {
  type    = string
  default = "0"
}

variable "machine_disk_size" {
  type    = string
  default = "40"
}

variable "eks_disable_public_ip" {
  type    = bool
  default = false
}

variable "container_images" {
  type = map(string)

  default = {
    "Hyperkube" = ""
    "CoreDNS"   = ""
    "Etcd"      = ""
  }
}

variable "private_default_gw" {
  type    = string
  default = ""
}

variable "private_vn_prefix" {
  type    = string
  default = ""
}

variable "cluster_members" {
  type    = list(string)
  default = ["master-0", "master-1"]
}

variable "customer_route" {
  type    = string
  default = ""
}

variable "cluster_latitude" {
  type    = string
  default = ""
}

variable "cluster_longitude" {
  type    = string
  default = ""
}

variable "cluster_workload" {
  type    = string
  default = ""
}

variable "cluster_labels" {
  type    = map(string)
  default = {}
}

variable "maurice_endpoint" {
  type    = string
  default = "https://register.ves.volterra.io"
}

variable "maurice_mtls_endpoint" {
  type    = string
  default = "https://register-tls.ves.volterra.io"
}

variable "machine_private_key" {
  type    = string
  default = ""
}

variable "machine_public_key" {
  type = string
}

variable "dns_zone_name" {
  type    = string
  default = ""
}

variable "dns_zone_suffix" {
  type    = string
  default = "example.com"
}

variable "vp_manager_version" {
  type    = string
  default = "latest"
}

variable "vp_manager_type" {
  type    = string
  default = "ce"
}

variable "vp_manager_skip_stages" {
  default     = []
  type        = list(string)
  description = "List of VP manager stages to skip"
}

variable "vp_manager_master_skip_stages" {
  default     = []
  type        = list(string)
  description = "List of VP manager stages to skip"
}

variable "pikachu_endpoint" {
  type    = string
  default = ""
}

variable "nic_private" {
  type    = string
  default = ""
}

variable "nic_inside" {
  type    = string
  default = ""
}

variable "certified_hardware_endpoint" {
  type    = string
  default = "https://vesio.blob.core.windows.net/releases/certified-hardware/aws.yml"
}

variable "sre_dns_service_ip" {
  type    = string
  default = ""
}

variable "fabric_address_pool" {
  type = string
}

variable "fabric_subnet_private" {
  type = string
}

variable "fabric_subnet_inside" {
  type = string
}

variable "eks_fabric_address_pool" {
  type    = string
  default = ""
}

variable "eks_cluster" {
  type    = bool
  default = true
}

variable "fabric_peering_network_id" {
  type    = string
  default = ""
}

variable "user_name" {
  type    = string
  default = "core"
}

variable "user_password" {
  type    = string
  default = ""
}

variable "local_ip" {
  type    = string
  default = ""
}

variable "eks_worker_vm_count" {
  type    = string
  default = 1
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

variable "enable_auto_registration" {
  type    = bool
  default = true
}

variable "iam_owner" {
  type = string
}

variable "aws_iam_authenticator_bin_path" {
  type    = string
  default = "/opt/homebrew/bin/aws-iam-authenticator"
}

variable "ce_disable_public_ip" {
  default = false
}

variable "ves_env" {
  default = "production"
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

variable "tunnel_interface_static_ip" {
  type = string
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