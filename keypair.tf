resource "tls_private_key" "utc_key" {
  rsa_bits  = 4096
  algorithm = "RSA"
}

# Renamed to match the 'depends_on' in your ec2.tf
resource "local_file" "utc_pem" {
  filename        = "${var.utc_key}.pem"
  content         = tls_private_key.utc_key.private_key_pem
  file_permission = "0400"
}

# Renamed to match the 'key_name' reference in your ec2.tf
resource "aws_key_pair" "utc_key_pair" {
  public_key = tls_private_key.utc_key.public_key_openssh
  key_name   = var.utc_key
}