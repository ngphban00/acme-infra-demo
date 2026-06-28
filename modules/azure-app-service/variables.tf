variable "name" {
  type        = string
  description = "Application name"
}

variable "environment" {
  type        = string
  description = "Environment name"

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, test, staging, or prod."
  }
}

variable "cost_center" {
  type        = string
  description = "Cost center for chargeback/showback"
}

variable "owner" {
  type        = string
  description = "Owning team"
}

variable "index_html_path" {
  type        = string
  description = "Path to index.html template"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
  default     = "southeastasia"
}

variable "sku_name" {
  type        = string
  description = "App Service Plan SKU (max B1 enforced by Sentinel policy)"
  default     = "B1"
}
