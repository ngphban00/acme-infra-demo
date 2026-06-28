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
  client_id       = "9c315f24-a7d6-4e72-96de-6ad6c4f3abca"
  tenant_id       = "9ae65231-1a32-4e61-876a-fe0b6857448d"
  subscription_id = "e3c6dd58-2eb8-4e7b-957f-6a4945309c10"
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
