output "private_ip_address" {
  value = module.ce_master.private_ip_address
}

output "public_ip_address" {
  value = module.ce_master.ip_address
}

output "slo_network" {
  value = module.ce_network.slo_network
}

output "slo_subnetwork" {
  value = module.ce_network.slo_subnetwork
}

output "sli_network" {
  value = module.ce_network.sli_network
}

output "sli_subnetwork" {
  value = module.ce_network.sli_subnetwork
}