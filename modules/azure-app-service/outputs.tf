output "website_endpoint" {
  value = "https://${azurerm_linux_web_app.site.default_hostname}"
}

output "app_name" {
  value = azurerm_linux_web_app.site.name
}
