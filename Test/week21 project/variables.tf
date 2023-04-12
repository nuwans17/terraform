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

variable "availability_sub_az_a" {
  type    = string
  default = "us-east-1a"
}

variable "availability_sub_az_b" {
  type    = string
  default = "us-east-1b"
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
        sudo yum update -y
        sudo yum install -y httpd
        sudo systemctl start httpd
        sudo systemctl enable httpd
        echo "<h1>Test AWS</h1>" | sudo tee /var/www/html/index.html
        sudo systemctl restart httpd
EOF
}

variable "variables_sub_cidr_a" {
  description = "CIDR Block for the Variables Subnet"
  type        = string
  default     = "172.31.30.0/24"
}

variable "variables_sub_cidr_b" {
  description = "CIDR Block for the Variables Subnet"
  type        = string
  default     = "172.31.20.0/24"
}


variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "wk20bkt"
}

