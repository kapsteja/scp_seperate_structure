terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "YOUR_ORG_NAME"  # Replace with your Terraform Cloud organization name

    workspaces {
      # This configuration uses tags to organize workspaces
      # Create two workspaces in Terraform Cloud:
      # 1. scp-deny (for Deny policies)
      # 2. scp-others (for Other policies)
      # 
      # To switch workspaces:
      # cd Deny && terraform workspace select scp-deny
      # cd others && terraform workspace select scp-others
      tags = ["scp-management"]
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Change if needed
}

