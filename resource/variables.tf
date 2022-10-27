
locals {
  vpc_name        = "cookalone-dev"
  cidr            = "10.194.0.0/16" # ip (cidr)
  public_subnets  = ["10.194.0.0/24", "10.194.1.0/24"]
  private_subnets = ["10.194.100.0/24", "10.194.101.0/24"]
  private_data_subnets = ["10.194.102.0/24", "10.194.103.0/24"]
  azs             = ["ap-northeast-1a", "ap-northeast-1c"] # 리전
  cluster_name    = "cookalone-dev-cluster"
}

variable "my-ip-address" {
  description = "Enter the IP address that connects to the Bastion EC2"
  default = ["218.156.136.117/32"]
}

variable "worker-instance-types" {
  description = "Maximum number of worker nodes in private subnet."
  default = [ "t3.medium" ]
  type        = list(string)
}

variable "worker-disk-size" {
  description = "Minimum number of worker nodes in private subnet."
  default = 30
  type        = number
}

// Worker Node
variable "worker-size" {
  description = "Worker Node Size"
  type        = map(string)
  default = {
    "desired" = "2"
    "min"     = "2"
    "max"     = "2"
  }
}