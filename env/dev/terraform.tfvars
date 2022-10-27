# saedul/env/dev/terraform.tfvars

  env                   = "cookalone"
  cidr                  = "10.185.0.0/16" # ip (cidr)
  public_subnets        = ["10.185.0.0/24", "10.185.1.0/24"]
  private_subnets       = ["10.185.100.0/24", "10.185.101.0/24"]
  private_data_subnets  = ["10.185.102.0/24", "10.185.103.0/24"]
  my-ip-address         = ["218.156.136.117/32"]
  worker-instance-types = [ "m5.xlarge" ]
  worker-disk-size      = 50
  worker-size           = {
    "desired" = "2"
    "min"     = "2"
    "max"     = "2"
  }
  db_engine             = "aurora-mysql"
  db_engine_version     = "8.0.mysql_aurora.3.02.1"
  azs                   = ["ap-south-1a", "ap-south-1c"] 