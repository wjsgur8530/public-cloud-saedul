# saedul/env/dev/variables.tf

variable "azs" {
  description = "region"
}

variable "env" {
  description = "env name"
  default     = ""
}

variable "cidr" {
  description = "vpc cidr"
}

variable "public_subnets" {
  description = "public subnets"
}

variable "private_subnets" {
  description = "private subnet"
}

variable "private_data_subnets" {
  description = "private data subnets"
}

variable "my-ip-address" {
  description = "Enter the IP address that connects to the Bastion EC2"
}

variable "worker-instance-types" {
  description = "Maximum number of worker nodes in private subnet."
  type        = list(string)
}

variable "worker-disk-size" {
  description = "Minimum number of worker nodes in private subnet."
  type        = number
}

variable "worker-size" {
  description = "Worker Node Size"
  type        = map(string)
} # worker node

variable "db_engine" {
  description = "database engine"
}

variable "db_engine_version" {
  description = "database engine version"
}