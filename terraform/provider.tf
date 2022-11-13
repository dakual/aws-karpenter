terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.39.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "Karpenter-Demo"
    }
  }
}