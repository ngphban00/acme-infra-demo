# ACME Infra Demo

Demo repo for ACME Order Portal — a static website provisioned via Terraform Cloud on AWS and Azure.

## Structure

```
acme-infra-demo/
├── docs/
│   └── oidc-azure.md         # OIDC setup guide for Azure
├── modules/
│   ├── aws-static-site/      # Reusable S3 static site module
│   └── azure-static-site/    # Reusable Azure Storage static site module
└── envs/
    └── dev/
        ├── aws/              # Dev environment on AWS  (workspace: acme-order-aws-dev)
        └── azure/            # Dev environment on Azure (workspace: acme-order-azure-dev)
```

## Prerequisites

- Terraform >= 1.6.0
- Terraform Cloud account, org `acme-demo`
- Workspaces `acme-order-aws-dev` and `acme-order-azure-dev` created in Terraform Cloud

## Usage

```bash
# AWS
cd envs/dev/aws
terraform login
terraform init
terraform plan
terraform apply

# Azure
cd envs/dev/azure
terraform login
terraform init
terraform plan
terraform apply
```

After apply, open the `website_endpoint` output URL to verify the site is live.

## Authentication

| Cloud | Method | Setup guide |
|-------|--------|-------------|
| AWS | OIDC dynamic credentials via Variable Set | — |
| Azure | OIDC dynamic credentials via Variable Set | [docs/oidc-azure.md](docs/oidc-azure.md) |

## Key Terraform Cloud Variable Set variables

### AWS (`aws-oidc-dev`)

| Variable | Type | Sensitive |
|----------|------|-----------|
| `TFC_AWS_PROVIDER_AUTH` | env | No |
| `TFC_AWS_PLAN_ROLE_ARN` | env | No |
| `TFC_AWS_APPLY_ROLE_ARN` | env | No |

### Azure (`azure-oidc-dev`)

| Variable | Type | Sensitive |
|----------|------|-----------|
| `TFC_AZURE_PROVIDER_AUTH` | env | No |
| `TFC_AZURE_CLIENT_ID` | env | No |
| `TFC_AZURE_TENANT_ID` | env | No |
| `TFC_AZURE_SUBSCRIPTION_ID` | env | No |
