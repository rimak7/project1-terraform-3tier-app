# 1. Bastion Host (Public Subnet)
resource "aws_instance" "bastion" {
  ami                         = var.ami_id # Use variable instead of data source
  instance_type               = var.instance_type # Use variable
  subnet_id                   = aws_subnet.pub["1a"].id 
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  key_name                    = aws_key_pair.utc_key_pair.key_name
  associate_public_ip_address = true
  
  depends_on = [local_file.utc_pem]

  user_data = file("user.sh")

  connection {
    type        = "ssh"
    user        = "ec2-user" # Assuming Amazon Linux 2 based on your AMI default
    private_key = tls_private_key.utc_key.private_key_pem
    host        = self.public_ip
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "./${aws_key_pair.utc_key_pair.key_name}.pem"
    destination = "/home/ec2-user/${aws_key_pair.utc_key_pair.key_name}.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ec2-user/${aws_key_pair.utc_key_pair.key_name}.pem"
    ]
  }

  tags = {
    Name = "bastion-host"
    env  = "dev"
    team = "config management"
  }
}

# 2. Private Server
resource "aws_instance" "private_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.priv["1a"].id 
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = aws_key_pair.utc_key_pair.key_name

  tags = {
    Name = "private-app-server"
    env  = "dev"
    team = "config management"
  }
}