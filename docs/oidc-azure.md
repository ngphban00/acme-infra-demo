# OIDC Dynamic Credentials — Azure

Allows workspace `acme-order-azure-dev` to authenticate with Azure without
storing any client secret in Terraform Cloud.

---

## How it works

```
Terraform Cloud run
  │
  ├─ generates JWT token containing: org, workspace, run phase
  │
  └─► Azure AD
        ├─ verifies token via Workload Identity Federation
        └─► returns short-lived access token (15 min)
              └─► azurerm provider uses token to call Azure API
```

---

## Step 1 — Create an App Registration

```bash
az ad app create --display-name "terraform-cloud-acme-order-azure-dev"
```

Note the `appId` (client ID) and `id` (object ID) from the output.

---

## Step 2 — Create a Service Principal

```bash
az ad sp create --id <appId>
```

---

## Step 3 — Assign Contributor role on the subscription

```bash
az role assignment create \
  --assignee <appId> \
  --role Contributor \
  --scope /subscriptions/<subscription-id>
```

For least-privilege, replace `Contributor` with a custom role scoped to only
create Resource Groups and Storage Accounts.

---

## Step 4 — Add a Federated Credential (Workload Identity Federation)

```bash
az ad app federated-credential create \
  --id <object-id> \
  --parameters '{
    "name": "tfc-acme-order-azure-dev",
    "issuer": "https://app.terraform.io",
    "subject": "organization:acme-demo:workspace:acme-order-azure-dev:run_phase:*",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

The `subject` must exactly match the workspace name in Terraform Cloud.
`:run_phase:*` allows both plan and apply.
To separate plan/apply permissions, create two federated credentials with
`run_phase:plan` and `run_phase:apply` and assign different roles to each.

---

## Step 5 — Create a Variable Set in Terraform Cloud

Go to **Organization Settings → Variable Sets → New Variable Set**.

Name: `azure-oidc-dev`
Scope: Project `Azure` (or workspace `acme-order-azure-dev`)

Add 4 **Environment variables**:

| Key | Value | Sensitive |
|-----|-------|-----------|
| `TFC_AZURE_PROVIDER_AUTH` | `true` | No |
| `TFC_AZURE_CLIENT_ID` | `<appId>` | No |
| `TFC_AZURE_TENANT_ID` | `<tenant-id>` | No |
| `TFC_AZURE_SUBSCRIPTION_ID` | `<subscription-id>` | No |

`ARM_CLIENT_SECRET` is not needed — this is the key difference from static credentials.

---

## Step 6 — Verify

Trigger a run in workspace `acme-order-azure-dev`.
The plan log should contain:

```
Configured Azure credentials from dynamic OIDC token
```

If you see error `AADSTS70021`, the `subject` in the federated credential does
not match the workspace name — revisit Step 4.
