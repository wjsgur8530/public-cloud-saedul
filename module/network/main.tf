# saedul/module/network/main.tf

# Create VPC
resource "aws_vpc" "main-vpc" {
  cidr_block           = var.vpc
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = { Name = "${var.env}-vpc" }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main-vpc.id
  service_name = "com.amazonaws.ap-south-1.s3"
  tags = {
    "Name" = "${var.env}-endpoint-s3"
  }
}

# Setting Subnet
# Create Public Subnet
resource "aws_subnet" "public-subnet" {
  count                   = length(var.public-subnet) # 여러개를 정의합니다
  cidr_block              = var.public-subnet[count.index]
  vpc_id                  = aws_vpc.main-vpc.id
  # 퍼플릭 서브넷에 배치되는 서비스는 자동으로 공개 IP를 부여합니다
  map_public_ip_on_launch = true

  availability_zone       = var.azs[count.index]
  tags = {
    Name = "${var.env}-public-${count.index + 1}",
    "kubernetes.io/cluster/${var.env}" = "shared", # 다른 부분
    "kubernetes.io/role/elb"                      = "1" # 다른 부분
  }
}

# Create Private Subnet
resource "aws_subnet" "private-subnet" {
  count = length(var.private-subnet) # 여러개를 정의합니다
  cidr_block        = var.private-subnet[count.index]
  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = var.azs[count.index]
  tags = {
    Name = "${var.env}-private-${count.index + 1}",
    "kubernetes.io/cluster/${var.env}" = "shared",
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
# Create Private Data Subnet
resource "aws_subnet" "private-data-subnets" {
  count = length(var.private-data-subnets) # 여러개를 정의합니다
  cidr_block        = var.private-data-subnets[count.index]
  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = var.azs[count.index]
  tags = {
    Name = "${var.env}-private-data-${count.index + 1}",
    "kubernetes.io/cluster/${var.env}" = "shared",
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

## Create Internet Gateway
resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.main-vpc.id

  tags   = { Name = "${var.env}-igw" }
}

# Create Public Route Table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }

  tags   = { Name = "${var.env}-public-table" }
}

# Create Public Route Table Routing
resource "aws_route_table_association" "public-route-table-association" {
  count = length(aws_subnet.public-subnet)

  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet[count.index].id
}

# Create EIP for Nat Gateway
resource "aws_eip" "nat-gateway-eip" {
  vpc   = true
  tags = { Name = "${var.env}-natgw-eip" }
}

# Create Nat Gateway
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-gateway-eip.id
  subnet_id     = aws_subnet.public-subnet[0].id

  tags          = { Name = "${var.env}-natgw" }
}

# Create Private Route Table !!!
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }
  tags   = { Name = "${var.env}-private" }
}


# Create Private Route Table Routing
resource "aws_route_table_association" "private-route-table-association" {
  count = length(var.private-subnet)

  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet[count.index].id
}

