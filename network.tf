# 1. VPC Definition
resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "my-vpc" }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags   = { Name = "main-igw" }
}

# 3. Public Subnets (using for_each for cleaner referencing)
resource "aws_subnet" "pub" {
  for_each = {
    "1a" = "10.10.7.0/24"
    "1b" = "10.10.8.0/24"
    "1d" = "10.10.10.0/24"
  }

  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = each.value
  availability_zone = "us-east-${each.key}"
  
  tags = { Name = "public-${each.key}" }
}

# 4. Private Subnets (Matches the "priv" reference in your ec2.tf)
resource "aws_subnet" "priv" {
  for_each = {
    "1a" = "10.10.1.0/24"
    "1b" = "10.10.2.0/24"
    "1c" = "10.10.3.0/24"
    "1d" = "10.10.4.0/24"
    "1e" = "10.10.5.0/24"
    "1f" = "10.10.6.0/24"
  }

  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = each.value
  availability_zone = "us-east-${each.key}"

  tags = { Name = "private-${each.key}" }
}

# 5. NAT Gateways (One per Public Subnet for HA)
resource "aws_eip" "nat" {
  for_each = aws_subnet.pub
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  for_each      = aws_subnet.pub
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.pub[each.key].id
  
  tags = { Name = "nat-gw-${each.key}" }
}

# 6. Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = { Name = "public-rt" }
}

# 7. Private Route Tables (One per NAT Gateway to prevent RouteAlreadyExists)
resource "aws_route_table" "private" {
  for_each = aws_subnet.pub
  vpc_id   = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.key].id
  }

  tags = { Name = "private-rt-${each.key}" }
}

# 8. Associations
# Link all public subnets to the public route table
resource "aws_route_table_association" "pub_assoc" {
  for_each       = aws_subnet.pub
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Link private subnets to their respective AZ NAT Gateways
resource "aws_route_table_association" "priv_assoc" {
  for_each  = aws_subnet.priv
  subnet_id = each.value.id
  
  # Logic: Map 1a to rt-1a, 1b to rt-1b, others default to rt-1d
  route_table_id = lookup(aws_route_table.private, each.key, aws_route_table.private["1d"]).id
}