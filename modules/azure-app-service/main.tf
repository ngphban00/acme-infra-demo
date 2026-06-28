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

resource "azurerm_linux_web_app" "site" {
  name                = "${var.name}-${var.environment}-${random_id.suffix.hex}"
  resource_group_name = azurerm_resource_group.site.name
  location            = azurerm_resource_group.site.location
  service_plan_id     = azurerm_service_plan.site.id

  site_config {
    always_on = false

    application_stack {
      docker_image_name   = "nginx:alpine"
      docker_registry_url = "https://index.docker.io"
    }

    # Write HTML from env var then start nginx in foreground
    app_command_line = "sh -c \"printenv INDEX_HTML_B64 | base64 -d > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'\""
  }

  app_settings = {
    "WEBSITES_PORT"  = "80"
    "INDEX_HTML_B64" = base64encode(templatefile(var.index_html_path, {
      environment = var.environment
      cost_center = var.cost_center
      owner       = var.owner
    }))
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
