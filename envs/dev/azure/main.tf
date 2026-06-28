terraform {
  required_version = ">= 1.6.0"

  cloud {
    organization = "acme-demo"

    workspaces {
      name = "acme-order-azure-dev"
    }
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

module "order_portal" {
  source = "../../../modules/azure-static-site"

  name            = "acme-order-portal"
  environment     = var.environment
  cost_center     = var.cost_center
  owner           = var.owner
  azure_region    = var.azure_region
  index_html_path = "${path.module}/index.html"
}
