resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.10.0.0/16"
  region               = "us-east-1"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
}
#private subnet
resource "aws_subnet" "my_private_subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "my_private_subnet1"
  }

}

resource "aws_subnet" "my_private_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "my_private_subnet2"
  }

}
resource "aws_subnet" "my_private_subnet3" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "my_private_subnet3"
  }

}
resource "aws_subnet" "my_private_subnet4" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.10.4.0/24"
  availability_zone = "us-east-1d"
  tags = {
    Name = "my_private_subnet4"
  }

}
resource "aws_subnet" "my_private_subnet5" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.10.5.0/24"
  availability_zone = "us-east-1e"
  tags = {
    Name = "my_private_subnet5"
  }

}

resource "aws_subnet" "my_private_subnet6" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.10.6.0/24"
  availability_zone = "us-east-1f"
  tags = {
    Name = "my_private_subnet6"
  }

}
#public subnet

resource "aws_subnet" "my_public_subnet1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.10.7.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "my_public_subnet1"
  }

}

resource "aws_subnet" "my_public_subnet2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.10.8.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "my_public_subnet2"
  }

}

resource "aws_subnet" "my_public_subnet3" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.10.10.0/24"
  availability_zone = "us-east-1d"
  tags = {
    Name = "my_public_subnet3"
  }
}

#create EIP for nat gateway
resource "aws_eip" "my_nat_eip1" {
}
resource "aws_eip" "my_nat_eip2" {

}
resource "aws_eip" "my_nat_eip3" {
  
}
# Nat gateway subnet

resource "aws_nat_gateway" "my_nat_subnet1" {
  subnet_id     = aws_subnet.my_public_subnet1.id
  allocation_id = aws_eip.my_nat_eip.id
  tags = {
    Name = "my_nat_subnet1"
  }
}

resource "aws_nat_gateway" "my_nat_subnet2" {
  subnet_id     = aws_subnet.my_public_subnet2.id
  allocation_id = aws_eip.my_nat_eip.id
  tags = {
    Name = "my_nat_subnet2"
  }
}

resource "aws_nat_gateway" "my_nat_subnet3" {
  subnet_id     = aws_subnet.my_public_subnet3.id
  allocation_id = aws_eip.my_nat_eip.id
  tags = {
    Name = "my_nat_subnet3"
  }
}
#internet gateway 
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_igw"
  }
}
#route table for public subnet
resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}
#route table for private subnet
resource "aws_route_table" "my_private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_subnet1.id
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_subnet2.id
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat_subnet3.id
  }
}


#associate public subnet with route table
resource "aws_route_table_association" "my_public_subnet1_association" {
  subnet_id      = aws_subnet.my_public_subnet1.id
  route_table_id = aws_route_table.my_public_route_table.id
}
resource "aws_route_table_association" "my_public_subnet2_association" {
  subnet_id      = aws_subnet.my_public_subnet2.id
  route_table_id = aws_route_table.my_public_route_table.id
}
resource "aws_route_table_association" "my_public_subnet3_association" {
  subnet_id      = aws_subnet.my_public_subnet3.id
  route_table_id = aws_route_table.my_public_route_table.id
}

#associate private subnet with route table
resource "aws_route_table_association" "my_private_subnet1_association" {
  subnet_id      = aws_subnet.my_private_subnet1.id
  route_table_id = aws_route_table.my_private_route_table.id
}
resource "aws_route_table_association" "my_private_subnet2_association" {
  subnet_id      = aws_subnet.my_private_subnet2.id
  route_table_id = aws_route_table.my_private_route_table.id
}
resource "aws_route_table_association" "my_private_subnet3_association" {
  subnet_id      = aws_subnet.my_private_subnet3.id
  route_table_id = aws_route_table.my_private_route_table.id
}
resource "aws_route_table_association" "my_private_subnet4_association" {
  subnet_id      = aws_subnet.my_private_subnet4.id
  route_table_id = aws_route_table.my_private_route_table.id
}
resource "aws_route_table_association" "my_private_subnet5_association" {
  subnet_id      = aws_subnet.my_private_subnet5.id
  route_table_id = aws_route_table.my_private_route_table.id
}
resource "aws_route_table_association" "my_private_subnet6_association" {
  subnet_id      = aws_subnet.my_private_subnet6.id
  route_table_id = aws_route_table.my_private_route_table.id
}
