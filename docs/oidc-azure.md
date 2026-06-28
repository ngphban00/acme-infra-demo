# OIDC Dynamic Credentials — Azure (Workload Identity Federation)

Allows workspace `static-site-azure-dev` to authenticate with Azure without
storing any long-lived `ARM_CLIENT_SECRET` in HCP Terraform.

Reference: https://developer.hashicorp.com/terraform/cloud-docs/dynamic-provider-credentials/azure-configuration

---

## Requirements

- AzureRM provider >= 3.25.0 (use `~> 3.100` to be safe)
- HCP Terraform workspace
- Azure App Registration + Service Principal
- Federated Identity Credential in Microsoft Entra ID

---

## How it works

```
HCP Terraform run
  │
  ├─ generates short-lived OIDC token
  │    (issuer: https://app.terraform.io)
  │
  └─► Azure AD validates federated credential
        (issuer / audience / subject must match)
        │
        └─► issues short-lived access token
              └─► AzureRM provider provisions resources
                    token expires after run
```

---

## Step 1 — Create App Registration

In Azure Portal: Microsoft Entra ID → App registrations → New registration

```
Name: hcp-terraform-acme-order-dev
```

Note the **Application (client) ID**, **Directory (tenant) ID**, and your **Subscription ID**.

Or via CLI:
```bash
az ad app create --display-name "hcp-terraform-acme-order-dev"
az ad sp create --id <appId>
```

---

## Step 2 — Assign RBAC role

```bash
az role assignment create \
  --assignee <appId> \
  --role Contributor \
  --scope /subscriptions/<subscription-id>
```

For least-privilege, use a custom role scoped to only create Resource Groups
and Storage Accounts.

---

## Step 3 — Add Federated Identity Credential

In Azure Portal: App Registration → Certificates & secrets → Federated credentials → Add credential

Choose scenario: **Other issuer**

```
Issuer:   https://app.terraform.io
Audience: api://AzureADTokenExchange
Subject:  organization:ngphban:workspace:static-site-azure-dev:run_phase:*
```

Or via CLI:
```bash
az ad app federated-credential create \
  --id <object-id> \
  --parameters '{
    "name": "tfc-static-site-azure-dev",
    "issuer": "https://app.terraform.io",
    "subject": "organization:ngphban:workspace:static-site-azure-dev:run_phase:*",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

The `subject` must exactly match the HCP Terraform org and workspace name.
Use `run_phase:plan` / `run_phase:apply` to separate permissions per phase.

---

## Step 4 — Configure workspace variables in HCP Terraform

In workspace `static-site-azure-dev` → Variables → add **Environment variables**:

| Key | Value | Sensitive |
|-----|-------|-----------|
| `TFC_AZURE_PROVIDER_AUTH` | `true` | No |
| `TFC_AZURE_RUN_CLIENT_ID` | `<Application client ID>` | No |
| `ARM_TENANT_ID` | `<Directory tenant ID>` | No |
| `ARM_SUBSCRIPTION_ID` | `<Subscription ID>` | No |

Note: `TFC_AZURE_RUN_CLIENT_ID` — NOT `TFC_AZURE_CLIENT_ID`.
No `ARM_CLIENT_SECRET` needed — this is the key benefit.

---

## Step 5 — Provider config (minimal)

```hcl
provider "azurerm" {
  features {}
}
```

No `use_oidc = true` needed in provider block. HCP Terraform injects
`ARM_USE_OIDC`, `ARM_OIDC_TOKEN`, `ARM_CLIENT_ID` automatically when
`TFC_AZURE_PROVIDER_AUTH=true` is set.

---

## Step 6 — Verify

Trigger a run. Plan log should show:

```
Configured Azure credentials from dynamic OIDC token
```

If you see `AADSTS70021` → subject in federated credential does not match
workspace name — revisit Step 3.
