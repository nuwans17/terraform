
#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

locals {
  team        = "aws_instance"
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

data "aws_vpc" "default" {
  default = true
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

}

#Deploy the public subnets
resource "aws_subnet" "subnet_a" {
    vpc_id                  = var.vpc_id
    cidr_block              = var.variables_sub_cidr_a
    map_public_ip_on_launch = true
    availability_zone       = var.availability_sub_az_a
  }

resource "aws_subnet" "subnet_b" {
    vpc_id                  = var.vpc_id
    cidr_block              = var.variables_sub_cidr_b
    map_public_ip_on_launch = true
    availability_zone       = var.availability_sub_az_b
  }

# Define launch_configuration

resource "aws_launch_configuration" "example" {
  name            = local.server-name
  image_id        = data.aws_ami.amazon_linux_2.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web_server.id]
  user_data = var.ec2_user_data

  # Required when using a launch configuration with an auto scaling group.
  lifecycle {
    create_before_destroy = true
  }
}

# Define Auto Scaling Group

resource "aws_autoscaling_group" "example" {
  name                 = "luit-asg-wk21"     
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = [aws_subnet.subnet_a.id, aws_subnet.subnet_b.id]

  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type ="ELB"
  desired_capacity = 3
  min_size = 2
  max_size = 5

  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

#Deploy the public subnets
#resource "aws_subnet" "my_subnet" {
#    vpc_id                  = var.vpc_id
#    cidr_block              = var.variables_sub_cidr
#    map_public_ip_on_launch = true
#  }


# Define the ALB

resource "aws_lb" "example" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.alb.id}"]
  subnets            = ["${aws_subnet.subnet_a.id}" , "${aws_subnet.subnet_b.id}"]
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


# Define the Security group and the rules

resource "aws_security_group" "web_server" {
  name        = "web_server"
  description = "Allow inbound traffic on tcp/80 & SSH 22"
  vpc_id = aws_default_vpc.default.id

  ingress {
    description     = "Allow 80 from the ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name    = "web_server"
    Purpose = "Manage inbound traafic"
  }
}


resource "aws_security_group" "alb" {
  name = "terraform-example-alb"

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Define the  S3 bucket with disable public access_key

resource "aws_s3_bucket" "wk21bkt" {
  bucket = var.bucket_name

  tags = {
    Name        = "My bucket"
    Environment = "Prd"
  }
}

# Block all public access to the S3 bucket

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.wk21bkt.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



