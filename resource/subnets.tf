# Setting Subnet
# Create Public Subnet
resource "aws_subnet" "public-subnet" {
  count                   = length(local.public_subnets) # 여러개를 정의합니다
  cidr_block              = local.public_subnets[count.index]
  vpc_id                  = aws_vpc.main-vpc.id
  # 퍼플릭 서브넷에 배치되는 서비스는 자동으로 공개 IP를 부여합니다
  map_public_ip_on_launch = true

  availability_zone       = local.azs[count.index]
  tags = {
    Name = "${local.vpc_name}-public-${count.index + 1}",
    "kubernetes.io/cluster/${local.cluster_name}" = "shared", # 다른 부분
    "kubernetes.io/role/elb"                      = "1" # 다른 부분
  }
}

# Create Private Subnet
resource "aws_subnet" "private-subnet" {
  count = length(local.private_subnets) # 여러개를 정의합니다
  cidr_block        = local.private_subnets[count.index]
  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = local.azs[count.index]
  tags = {
    Name = "${local.vpc_name}-private-${count.index + 1}",
    "kubernetes.io/cluster/${local.cluster_name}" = "shared",
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
# Create Private Data Subnet
resource "aws_subnet" "private-data-subnet" {
  count = length(local.private_data_subnets) # 여러개를 정의합니다
  cidr_block        = local.private_data_subnets[count.index]
  vpc_id            = aws_vpc.main-vpc.id
  availability_zone = local.azs[count.index]
  tags = {
    Name = "${local.vpc_name}-private-data-${count.index + 1}",
    "kubernetes.io/cluster/${local.cluster_name}" = "shared",
    "kubernetes.io/role/internal-elb"             = "1"
  }
}