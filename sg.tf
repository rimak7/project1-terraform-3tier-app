# 1. ALB Security Group: Inbound 80/443 from everywhere
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "External Load Balancer traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Bastion Host Security Group: Inbound 22 from your IP only
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Management access"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP_HERE/32"] # Be sure to update this!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. App Server Security Group: Inbound from ALB (80) and Bastion (22)
resource "aws_security_group" "app_sg" {
  name        = "app-server-sg"
  description = "Application tier traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description     = "Allow SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 4. Database Security Group: Inbound 3306 from App Server only
resource "aws_security_group" "db_sg" {
  name        = "database-sg"
  description = "Database tier traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description     = "Allow MySQL from App Server"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}