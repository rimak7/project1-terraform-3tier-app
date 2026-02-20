# 1. Bastion Host (Public Subnet)
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon.id
  instance_type               = "t2.micro"
  # FIXED: Matches the key name in your loop
  subnet_id                   = aws_subnet.pub["1a"].id 
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = aws_key_pair.utc_key_pair.key_name
  associate_public_ip_address = true
  
  # CRITICAL: Ensures the .pem file is created on the runner BEFORE provisioners run
  depends_on = [local_file.utc_pem]

  user_data = file("user.sh")

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.utc_key.private_key_pem
    host        = self.public_ip
    timeout     = "2m" # Gives the instance time to boot
  }

  provisioner "file" {
    source      = "./utc-key.pem"
    destination = "/home/ec2-user/utc-key.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/utc-key.pem"
    ]
  }

  tags = {
    Name = "bastion-host"
    env  = "dev"
    team = "config management"
  }
}

# 2. Private Server (Private Subnet)
resource "aws_instance" "private_server" {
  ami                    = data.aws_ami.amazon.id
  instance_type          = "t3.micro"
  # FIXED: Pointing to your private subnet map
  subnet_id              = aws_subnet.priv["1a"].id 
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = aws_key_pair.utc_key_pair.key_name

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