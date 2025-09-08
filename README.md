# Terraform

```
├── environments
│   ├── prod
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── variables.tf
│   └── staging
│       ├── backend.tf
│       ├── main.tf
│       ├── terraform.tfvars
│       └── variables.tf
├── modules
│   ├── iam
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   └── s3-bucket
│       ├── iam.tf
│       ├── main.tf
│       ├── output.tf
│       └── variables.tf
├── providers.tf
├── README.md
├── variables.tf
└── versions.tf
```