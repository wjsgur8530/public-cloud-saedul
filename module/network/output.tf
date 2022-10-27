# saedul/module/network/output.tf

output "vpc" {
  value = aws_vpc.main-vpc.id
}

output "public-subnet" {
  value = aws_subnet.public-subnet[*].id
}

output "private-subnet" {
  value = aws_subnet.private-subnet[*].id
}

output "private-data-subnets" {
  value = aws_subnet.private-data-subnets[*].id
}

output "endpoint" {
  value = aws_vpc_endpoint.s3.id
}