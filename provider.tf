terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "YOUR_ORG_NAME"  # Replace with your Terraform Cloud org

    workspaces {
      # Two workspaces: one for Deny, one for Others
      # Use: terraform cloud select-workspace scp-deny or scp-others
      name = "scp-terraform"  # Default workspace; override with TF_WORKSPACE env var
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

