variable "utc_key" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
  default     = "my-ssh-key"

}
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}
variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0f3caa1cf4417e51b" 
}
