# ACME Infra Demo

Demo repo for ACME Order Portal — a static website provisioned via Terraform Cloud.

## Structure

```
acme-infra-demo/
├── modules/
│   └── static-site/      # Reusable S3 static site module
└── envs/
    └── dev/              # Dev environment (workspace: acme-order-dev)
```

## Prerequisites

- Terraform >= 1.6.0
- Terraform Cloud account, org `acme-demo`, workspace `acme-order-dev`
- AWS credentials set as workspace variables in Terraform Cloud

## Usage

```bash
cd envs/dev
terraform login
terraform init
terraform plan
terraform apply
```

After apply, open the `website_endpoint` output URL to verify the site is live.

## Key variables (set in Terraform Cloud workspace)

| Variable | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | AWS env var (sensitive) |
| `AWS_SECRET_ACCESS_KEY` | AWS env var (sensitive) |
| `cost_center` | Cost center tag for chargeback |
| `owner` | Owning team tag |
