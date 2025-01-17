# AWS Region
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

# VPC Name
variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "Example-VPC"
}


## Postgres

# Postgres User
variable "postgres_user" {
  description = "Postgres default user"
  type        = string
  default     = "postgres"
}

# Postgres Password
variable "postgres_pw" {
  description = "Postgres default user"
  type        = string
  default     = "my-secure-pw"
}


## VPC & Subnets

# VPC CIDR
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.10.0.0/16"
}

# Public Subnets CIDR (Loop)
variable "subnets_public_cidr" {
  type    = list(string)
  default = ["10.10.0.0/24", "10.10.1.0/24"]
}

# Public Subnets AZ (Loop)
variable "subnets_public_azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}


## EC2 Instances

# SSH key pair name
variable "key_name" {
  default = "us-east-1-pc-le" # Define key pair name
}

# EC2 Image ID
variable "ami_id" {
  default = "ami-0e2c8caa4b6378d8c" # Define EC2 AMI ID
}