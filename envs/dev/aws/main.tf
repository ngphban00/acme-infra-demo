terraform {
  required_version = ">= 1.6.0"

  cloud {
    organization = "acme-demo"

    workspaces {
      name = "acme-order-aws-dev"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

provider "aws" {
  region = var.aws_region
}

module "order_portal" {
  source = "../../../modules/aws-elastic-beanstalk"

  name            = "acme-order-portal"
  environment     = var.environment
  cost_center     = var.cost_center
  owner           = var.owner
  aws_region      = var.aws_region
  index_html_path = "${path.module}/index.html"
}
