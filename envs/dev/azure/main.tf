terraform {
  required_version = ">= 1.6.0"

  cloud {
    organization = "ngphban"

    workspaces {
      name = "static-site-azure-dev"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "order_portal" {
  source = "../../../modules/azure-app-service"

  name            = "acme-order-portal"
  environment     = var.environment
  cost_center     = var.cost_center
  owner           = var.owner
  azure_region    = var.azure_region
  index_html_path = "${path.module}/index.html"
}
