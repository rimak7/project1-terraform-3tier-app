variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "utc_key" {
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
  default     = "utc-key"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0f3caa1cf4417e51b" # Amazon Linux 2 AMI
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

# Environment tags for consistency
variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "team" {
  description = "Team responsible for the infrastructure"
  type        = string
  default     = "config management"
}