terraform {
  required_version = ">= 1.2.3"

  required_providers {
    volterra = {
      source  = "volterraedge/volterra"
      version = ">=0.11.9"
    }

    aws = {
      source  = "hashicorp/aws"
      version = ">=4.20.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }

    local = ">= 2.2.3"
    null  = ">= 3.1.1"
  }
}