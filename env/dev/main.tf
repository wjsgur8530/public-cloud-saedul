# saedul/env/dev/main.tf

## megazone account
provider "aws" {
  access_key = "access-key"
  secret_key = "secret-key"
  region     = "ap-south-1"
}


## module
module "bastion" {
  source                = "../../module/bastion"
  env                   = var.env
  vpc                   = module.network.vpc
  public-subnet         = module.network.public-subnet
  my-ip-address         = var.my-ip-address
}

module "eks" {
  source                = "../../module/eks"
  env                   = var.env
  vpc                   = module.network.vpc
  private-subnet        = module.network.private-subnet
  worker-disk-size      = var.worker-disk-size
  worker-instance-types = var.worker-instance-types
  worker-size           = var.worker-size
}

module "network" {
  source                = "../../module/network"
  azs                   = var.azs
  env                   = var.env
  vpc                   = var.cidr
  public-subnet         = var.public_subnets
  private-subnet        = var.private_subnets
  private-data-subnets  = var.private_data_subnets
}

module "rds" {
  source                = "../../module/rds"
  azs                   = var.azs
  env                   = var.env
  vpc                   = module.network.vpc
  db_engine             = var.db_engine
  db_engine_version     = var.db_engine_version
  private-data-subnets  = module.network.private-data-subnets
  public-subnet         = module.network.public-subnet
}

module "s3" {
  source                = "../../module/s3"
  env                   = var.env
  endpoint              = module.network.endpoint
}

module "ecr" {
  source                = "../../module/ecr"
  env                   = var.env
}