# Declare the Terraform configuration block and specify required providers.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
  }
}

# Configure the AWS provider with the desired region and credentials file.
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

data "aws_vpc" "default_vpc" {
  default = true  
}

data "aws_subnets" "default_subnet" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
    
  }
}

/*
# Define the Ec2 Instance to use as Webserver 
resource "aws_instance" "webserver" {
  ami                        = "ami-0c7217cdde317cfec"
  instance_type              = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.webserver-sg.id ]
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup busybox httpd -f -p ${var.web_server_port} &
  EOF
  user_data_replace_on_change = true
  tags = {
    Name    = "Web-server"
    Purpose = "Demo"
  }
}
*/

# Define the security group with ingress rule
resource "aws_security_group" "webserver-sg" {
  name = "terraform-example-instance"
  ingress {
    from_port   = var.web_server_port
    to_port     = var.web_server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

# Define the Launch Configuration to be used by the ASG
resource "aws_launch_configuration" "web_server_launch_config" {
  image_id = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  security_groups = [ aws_security_group.webserver-sg.id ]
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello, World From Sharjeel" > index.html
    nohup busybox httpd -f -p ${var.web_server_port} &
  EOF
  lifecycle {
    create_before_destroy = true
  }
}

# Define the ASG with Max and Min size 
resource "aws_autoscaling_group" "web_server_asg" {
  launch_configuration = aws_launch_configuration.web_server_launch_config.name
  vpc_zone_identifier =  data.aws_subnets.default_subnet.ids
  target_group_arns = [ aws_lb_target_group.alb-target-group.arn ]
  health_check_type = "ELB"
  min_size = 2
  max_size = 3
  tag  {
    key = "Name"
    value = "terraform-webserver-example"
    propagate_at_launch = true
  }  
}

# Create a Application Load Balancer that will route the traffic
resource "aws_alb" "web_server_alb" {
  name = "webserver-alb"
  load_balancer_type = "application"
  subnets =  data.aws_subnets.default_subnet.ids   
  security_groups = [ aws_security_group.alb-sg.id ]
}

# Define a listener for this ALB
resource "aws_lb_listener" "web_server_alb_listener" {
  load_balancer_arn = aws_alb.web_server_alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "fixed-response"
  # Define the fixed response for the listener
    fixed_response {
      content_type = "text/plain"
      message_body = "404 : Page not Found"
      status_code = "404"
    }
  }  
}

# Define security group for ASG
resource "aws_security_group" "alb-sg" {
  name = "ABL-SG"
  ingress {
    from_port =  80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"] 
  }
}

# Define the Target group for the ALB 
resource "aws_lb_target_group" "alb-target-group" {
  name = "alb-tg"
  port = var.web_server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default_vpc.id
  health_check {
      path = "/"
      protocol = "HTTP"
      matcher = "200"
      interval = 15
      timeout = 3
      healthy_threshold = 2
      unhealthy_threshold = 2
  }
}

# Define ALB Listener rule 
resource "aws_lb_listener_rule" "alb_listener_rule" {
  listener_arn = aws_lb_listener.web_server_alb_listener.arn
  condition {
    path_pattern {
      values = [ "*" ]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.alb-target-group.arn
  }
  
}

# Define the output to get the EC2 Public IP Address
output "public_ip" {
  description = "The public IP address of the web server"
  value = aws_alb.web_server_alb.dns_name
  
}

  
