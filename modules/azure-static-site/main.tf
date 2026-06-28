resource "random_id" "suffix" {
  byte_length = 4
}

resource "azurerm_resource_group" "site" {
  name     = "${var.name}-${var.environment}-rg"
  location = var.azure_region

  tags = local.common_tags
}

resource "azurerm_storage_account" "site" {
  # Storage account name: lowercase alphanumeric only, max 24 chars
  name                     = substr(replace("${var.name}${var.environment}${random_id.suffix.hex}", "-", ""), 0, 24)
  resource_group_name      = azurerm_resource_group.site.name
  location                 = azurerm_resource_group.site.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  static_website {
    index_document = "index.html"
  }

  tags = local.common_tags
}

resource "azurerm_storage_blob" "index" {
  name                   = "index.html"
  storage_account_name   = azurerm_storage_account.site.name
  storage_container_name = "$web"
  type                   = "Block"
  source_content         = templatefile(var.index_html_path, { environment = var.environment, cost_center = var.cost_center, owner = var.owner })
  content_type           = "text/html"
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
