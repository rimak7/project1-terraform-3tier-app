resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Public Subnets
resource "aws_subnet" "pub" {
  for_each          = { "1a" = "10.10.7.0/24", "1b" = "10.10.8.0/24", "1d" = "10.10.10.0/24" }
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = each.value
  availability_zone = "us-east-${each.key}"
  tags              = { Name = "public-${each.key}" }
}

# NAT Gateways & EIPs (Fixed: removed vpc_id)
resource "aws_eip" "nat" { for_each = aws_subnet.pub }
resource "aws_nat_gateway" "nat" {
  for_each      = aws_subnet.pub
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.pub[each.key].id
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table" "private" {
  for_each = aws_subnet.pub
  vpc_id   = aws_vpc.my_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.key].id
  }
}

# Associations
resource "aws_route_table_association" "pub_asc" {
  for_each       = aws_subnet.pub
  subnet_id      = aws_subnet.pub[each.key].id
  route_table_id = aws_route_table.public.id
}