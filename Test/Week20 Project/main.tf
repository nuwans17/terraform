
#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

locals {
  team        = "jenkins_instance"
  application = "corp_api"
  server-name = "ec2-${var.Environment}-api-${var.availability_zone_az}"
}

# Terraform Data Block - Lookup Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  owners = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

}

# Define Default VPC

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

#Deploy the public subnets
resource "aws_subnet" "my_subnet" {
    vpc_id                  = var.vpc_id
    cidr_block              = var.variables_sub_cidr
    map_public_ip_on_launch = true
  }


# Define the Security group and the rules

resource "aws_security_group" "web_server_inbound" {
  name        = "web_server_inbound"
  description = "Allow inbound traffic on tcp/8080 & SSH 22"
  vpc_id = aws_default_vpc.default.id

  ingress {
    description = "Allow 22 from the Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow 8080 from the Internet"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name    = "web_server_inbound"
    Purpose = "Manage inbound traafic"
  }
}


#Define the EC2 instance

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance
  subnet_id = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.web_server_inbound.id]
  user_data = var.ec2_user_data

  tags = {
    Name  = local.server-name
    Owner = local.team
    App   = local.application
  }
}

#Define the  S3 bucket with disable public access_key

resource "aws_s3_bucket" "wk20bkt" {
  bucket = var.bucket_name

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# Block all public access to the S3 bucket

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.wk20bkt.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



