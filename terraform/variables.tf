variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
  default     = "karpenter-demo"
}

variable "cluster_version" {
  type        = string
  description = "The version of the cluster"
  default     = "1.23"
}

variable "aws_region" {
  type        = string
  description = "AWS region to launch servers."
  default     = "eu-central-1"
}

variable "availability_zones" {
  description = "Availability zones"
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "CIDRs for private subnets in our VPC."
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "CIDRs for public subnets in our VPC."
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}