# OIDC dynamic credentials — no client secret stored in Terraform Cloud.
# Terraform Cloud generates a short-lived JWT token per run; Azure AD verifies
# it via Workload Identity Federation and returns a temporary access token.
#
# Set the following in a Terraform Cloud Variable Set (not checked in):
#   TFC_AZURE_PROVIDER_AUTH   = true          (env var)
#   TFC_AZURE_CLIENT_ID       = <app-client-id>
#   TFC_AZURE_TENANT_ID       = <tenant-id>
#   TFC_AZURE_SUBSCRIPTION_ID = <subscription-id>
#
# Setup guide: docs/oidc-azure.md

variable "arm_client_id" {
  type        = string
  description = "Azure App Registration client ID (set via TFC Variable Set)"
  default     = ""
}

variable "arm_tenant_id" {
  type        = string
  description = "Azure tenant ID (set via TFC Variable Set)"
  default     = ""
}

variable "arm_subscription_id" {
  type        = string
  description = "Azure subscription ID (set via TFC Variable Set)"
  default     = ""
}
