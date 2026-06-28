resource "random_id" "suffix" {
  byte_length = 4
}

resource "azurerm_resource_group" "site" {
  name     = "${var.name}-${var.environment}-rg"
  location = var.azure_region
  tags     = local.common_tags
}

resource "azurerm_service_plan" "site" {
  name                = "${var.name}-${var.environment}-plan"
  resource_group_name = azurerm_resource_group.site.name
  location            = azurerm_resource_group.site.location
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = local.common_tags
}

# Package rendered HTML + server script into zip for deployment
# Using explicit source blocks avoids the source_dir containing its own output_path
data "archive_file" "site" {
  type        = "zip"
  output_path = "${path.module}/.build/site.zip"

  source {
    content = templatefile(var.index_html_path, {
      environment = var.environment
      cost_center = var.cost_center
      owner       = var.owner
    })
    filename = "index.html"
  }

  source {
    content  = file("${path.module}/server.py")
    filename = "server.py"
  }
}

resource "azurerm_linux_web_app" "site" {
  name                = "${var.name}-${var.environment}-${random_id.suffix.hex}"
  resource_group_name = azurerm_resource_group.site.name
  location            = azurerm_resource_group.site.location
  service_plan_id     = azurerm_service_plan.site.id
  zip_deploy_file     = data.archive_file.site.output_path

  site_config {
    always_on        = false # required for F1 free tier
    app_command_line = "python3 /home/site/wwwroot/server.py"

    application_stack {
      python_version = "3.12"
    }
  }

  app_settings = {
    "WEBSITES_PORT"                  = "8080"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "false"
  }

  tags = local.common_tags
}

locals {
  common_tags = {
    application = var.name
    environment = var.environment
    cost_center = var.cost_center
    owner       = var.owner
    managed_by  = "terraform"
  }
}
