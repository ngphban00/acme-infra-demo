variable "name" {
  type        = string
  description = "Application name"
}

variable "environment" {
  type        = string
  description = "Environment name, for example dev or prod"

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
  description = "Path to index.html"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
  default     = "southeastasia"
}
