provider "aws" {
  region  = var.aws_region
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "web_sec_group" {
  name        = "web_sec_group"
  description = "web security group"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port = 80
    to_port = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration
resource "aws_launch_configuration" "web" {
  name_prefix     = "web-high-lc-"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = var.web_instance_type
  security_groups = [aws_security_group.web_sec_group.id]
  user_data       = file("server.sh")

  lifecycle {
    create_before_destroy = true
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group
resource "aws_autoscaling_group" "web" {
  name                 = "autoscale_group"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  load_balancers       = [aws_elb.web.name]

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = {
      Name   = "web_autoscaled"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elb
resource "aws_elb" "web" {
  name               = "web-elb"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.web_sec_group.id]
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  tags = {
    Name = "wb-high-elb"
  }
}

output "web_load_balancer_url" {
  value = aws_elb.web.dns_name
}