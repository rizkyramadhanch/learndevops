#VPC
resource "aws_vpc" "Cilsy-VPC" {
  cidr_block = var.vpc_cidr
  tags = {
    "Name" = "CilsyVPC"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "Cilsy-IGW" {
  vpc_id = aws_vpc.Cilsy-VPC.id
  tags = {
    "Name" = "main"
  }
}

#Subnets : public
resource "aws_subnet" "public" {
  count                   = length(var.subnets_cidr)
  vpc_id                  = aws_vpc.Cilsy-VPC.id
  cidr_block              = element(var.subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name" = "Subnet-${count.index + 1}"
  }
}

#Route table: attach internet gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.Cilsy-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Cilsy-IGW.id
  }
  tags = {
    "Name" = "publicRouteTable"
  }
}

#Route table association with public subnets
resource "aws_route_table_association" "a" {
  count          = length(var.subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}
