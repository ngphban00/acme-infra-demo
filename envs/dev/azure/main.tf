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
  use_oidc        = true
  client_id       = var.arm_client_id
  tenant_id       = var.arm_tenant_id
  subscription_id = var.arm_subscription_id
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
