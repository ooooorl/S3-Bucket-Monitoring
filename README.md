# Terraform

```
├── dev.tfvars              # Dev environment values
├── prod.tfvars             # Prod environment values
├── env.tf                  # Variable declarations (variable "..." blocks)
├── main.tf                 # Actual infra definition (S3 bucket, policies, etc.)
├── outputs.tf (optional)   # Outputs like bucket ARN, name, etc.
├── README.md               # Docs for usage
├── terraform.tfstate       # Current state (auto-generated)
└── terraform.tfstate.backup# Backup state (auto-generated)
```