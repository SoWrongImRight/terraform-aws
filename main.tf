provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "17vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24"]

  enable_ipv6 = true

  enable_nat_gateway = false
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "Public-Subnets"
  }

  tags = {
    Owner       = "user"
    Environment = "dev"
  }

  vpc_tags = {
    Name = "W17VPCs"
  }
}

variable "db_username" {
  default = "database_username"
}

variable "db_password" {
  default = "database_password"
}

# Default VPC subnet
resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1"

  tags = {
    Name = "Default subnet for VPC"
  }
}

# Create a database server
resource "aws_db_instance" "private_subnets" {
  allocated_storage = 10
  engine            = "mysql"
  engine_version    = "8.0.20"
  instance_class    = "db.t3.micro"
  name              = " initial_db"
  username          = var.db_username
  password          = var.db_password
}

# Create a Network Load Balancer
resource "aws_lb" "NLB17" {
  name               = "NLB17"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["subnet-013012a4e6cb93a89", "subnet-095dd91cd905a9ef2"]

  enable_deletion_protection = false
}
