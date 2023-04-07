variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "accesskey" {
  type    = string
  default = "AKIA5FQCVVZ34434CRNO"
}

variable "secretkey" {
  type    = string
  default = "oYKmLzU2trFJbUrI6dmRUZdGzy9b2dz8RTDFA2X4"
}


variable "vpc_name" {
  type    = string
  default = "default-vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "172.31.0.0/16"
}

variable "vpc_id" {
  type   = string
  default = "vpc-0c2b506e477d397b2"
}

variable "availability_zone_az" {
  type    = string
  default = "us-east-1a"
}

variable "Environment" {
  description = "Environment for deployment"
  type        = string
  default     = "dev"
}

variable "instance" {
  description = "Type of the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "ec2_user_data" {
  type    = string
  default = <<EOF
#!/bin/bash
# Install Jenkins and Java 
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key
sudo yum -y upgrade

# Add required dependencies for the jenkins package
sudo yum install java-11-openjdk
sudo yum install -y jenkins

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
EOF
}

variable "variables_sub_cidr" {
  description = "CIDR Block for the Variables Subnet"
  type        = string
  default     = "172.31.10.0/24"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "wk20bkt"
}

