# Terragrunt for INITOPS `bird-watching-buried-marks`

## Structure

This repository consists of modular folders, which are used to remove redundant dependency layers and enable modular per-component deployment during migration from Terraform.

```text
├── README.md
├── _common
│   ├── dns.hcl
│   ├── ec2.hcl
│   ├── eks.hcl
│   ├── iam.hcl
│   ├── jenkins.hcl
│   ├── landing.hcl
│   ├── rds.hcl
│   ├── region-generic.hcl
│   ├── s3.hcl
│   └── vpc.hcl
├── modules/
│   └── ...
├── bw-bm-tg
│   ├── env.hcl
│   └── eu-north-1
│       ├── region.hcl
│       └── ...
├── dev
│   ├── env.hcl
│   └── eu-north-1
│       ├── region.hcl
│       └── ...
├── prod
│   ├── env.hcl
│   └── eu-north-1
│       ├── region.hcl
│       └── ...
├── stage
│   ├── env.hcl
│   └── eu-north-1
│       ├── region.hcl
│       └── ...
└── root.hcl
```

## Remote State

Remote state backend from [`s3-bootstrap-tf`](https://github.com/INITOPS-TEAM/terraform-bird-watching-buried-marks/tree/main/s3-bootstrap-tf) is defined in `root.hcl`.

## Deployment steps

1. Choose environment you would like to deploy

   ```bash
   cd <env>
   ```

2. Change `root.hcl`, `env.hcl`, `region.hcl`, and `terragrunt.hcl` files in each subdirectory in desired region.

3. Log into existing AWS account.

4. Make sure you have all required images in ECR and log into AWS ECR.

   ```bash
   aws ecr get-login-password --region eu-north-1 | docker login --username AWS --password-stdin <aws-account-id>.dkr.ecr.eu-north-1.amazonaws.com
   ```

5. For planning, run `terragrunt run plan` from desired module directory or `terragrunt run plan --all` from directory level with `terragrunt.hcl`.

6. For applying, run `terragrunt run apply` from desired module directory or `terragrunt run apply --all` from directory level with `terragrunt.hcl`.

7. After the cluster is created, log into AWS EKS and export your `KUBE_CONFIG_PATH`.

   ```bash
   aws eks update-kubeconfig --name birdmarks-eks-<env> --region eu-north-1
   export KUBE_CONFIG_PATH="~/.kube/config"
   ```
