provider "google" {
  credentials = file(var.gcp_credentials_file_path)
  project     = var.gcp_project_name
  region      = var.region
  zone        = var.zone
}

provider "volterra" {
  api_p12_file = var.api_p12_file
  api_cert     = var.api_p12_file != "" ? "" : var.api_cert
  api_key      = var.api_p12_file != "" ? "" : var.api_key
  api_ca_cert  = var.api_ca_cert
  url          = var.api_url
}