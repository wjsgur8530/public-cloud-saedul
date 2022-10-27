## Create Internet Gateway
resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.main-vpc.id

  tags   = { Name = "${local.vpc_name}-igw" }
}

# Create Public Route Table
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }

  tags   = { Name = "${local.vpc_name}-public-table" }
}

# Create Public Route Table Routing
resource "aws_route_table_association" "public-route-table-association" {
  count = length(local.public_subnets)

  route_table_id = aws_route_table.public-route-table.id
  subnet_id      = aws_subnet.public-subnet.*.id[count.index]
}

# Create EIP for Nat Gateway
resource "aws_eip" "nat-gateway-eip" {
  vpc   = true
  tags = { Name = "${local.vpc_name}-natgw-eip" }
}

# Create Nat Gateway
resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.nat-gateway-eip.id
  subnet_id     = aws_subnet.public-subnet.0.id

  tags          = { Name = "${local.vpc_name}-natgw" }
}

# Create Private Route Table !!!
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }
  tags   = { Name = "${local.vpc_name}-private" }
}


# Create Private Route Table Routing
resource "aws_route_table_association" "private-route-table-association" {
  count = length(local.private_subnets)

  route_table_id = aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.private-subnet.*.id[count.index]
}

