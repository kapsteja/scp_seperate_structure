terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "YOUR_ORG_NAME"  # Replace with your Terraform Cloud organization name

    # Workspace will be specified using backend.conf or TF_WORKSPACE env var
    # This allows different directories to use different workspaces
  }
}

provider "aws" {
  region = "us-east-1"  # Change if needed
}

