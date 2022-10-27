# Create VPC
resource "aws_vpc" "main-vpc" {
  cidr_block           = local.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = { Name = local.vpc_name }
}

