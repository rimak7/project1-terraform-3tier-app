# 1. Bastion Host (Public Subnet)
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.my_public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = aws_key_pair.utc_key.key_name
  associate_public_ip_address = true

  # Connection block for provisioners
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.utc_key.private_key_pem
    host        = self.public_ip
  }

  # Provisioner to copy the key to the Bastion
  provisioner "file" {
    source      = "./utc-key.pem"
    destination = "/home/amazon/utc-key.pem"
  }

  # Provisioner to set permissions to 400
  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/amazon/utc-key.pem"
    ]
  }

  tags = {
    Name = "bastion-host"
    env  = "dev"
    team = "config management"
  }
}

# 2. Private Server (Private Subnet - No Direct SSH)
resource "aws_instance" "private_server" {
  ami                    = data.aws_ami.amazon.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.my_private_subnet1.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = aws_key_pair.utc_key.key_name

  tags = {
    Name = "private-app-server"
    env  = "dev"
    team = "config management"
  }
}
data "aws_ami" "amazon" {
  most_recent = true
  owners      = ["amazon"]
    filter {
        name   = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

