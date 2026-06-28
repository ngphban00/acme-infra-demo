output "website_endpoint" {
  value = azurerm_storage_account.site.primary_web_endpoint
}

output "bucket_name" {
  value = azurerm_storage_account.site.name
}
