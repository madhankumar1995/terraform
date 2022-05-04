locals {
  cluster_name       = "${var.environment}-doohp-eks"
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
}



module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  cidr                           = "10.10.0.0/16"
  azs                            = local.availability_zones
  enable_classiclink             = "false"
  enable_classiclink_dns_support = "false"
  enable_dns_hostnames           = "true"
  enable_dns_support             = "true"
  enable_nat_gateway             = true
  single_nat_gateway             = true
  instance_tenancy               = "default"

  private_subnets = [var.private_subnet_az1_cidr, var.private_subnet_az2_cidr, var.private_subnet_az3_cidr]
  public_subnets  = [var.public_subnet_az1_cidr, var.public_subnet_az2_cidr, var.public_subnet_az3_cidr]

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "Environment"                                 = var.environment
    "Name"                                        = "Doohp-${var.environment}"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

