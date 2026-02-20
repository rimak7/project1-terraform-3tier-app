resource "tls_private_key" "utc_key" {
  rsa_bits  = 4096
  algorithm = "RSA"
}
resource "local_file" "github_key" {
  filename        = "${aws_key_pair.utc_key_pair.key_name}.pem"
  content         = tls_private_key.utc_key.private_key_pem
  file_permission = "0400"
}
resource "aws_key_pair" "utc_key_pair" {
  public_key = tls_private_key.utc_key.public_key_openssh
  key_name   = var.utc_key
}
