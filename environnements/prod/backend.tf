# environnements/prod/backend.tf

terraform {
  # MODIFICATION : On met >= pour accepter ta version 1.15.2
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"
    }
  }

  backend "s3" {
    # MODIFICATION : Utilise le nom exact du bucket que tu as créé tout à l'heure
    bucket         = "agricam-terraform-state-kamga"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-locks"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Projet        = "AgriCam"
      Environnement = "prod"
      Proprietaire  = "kamgaramos@example.com" # Tu peux mettre ton vrai email
      ManagedBy     = "Terraform"
    }
  }
}