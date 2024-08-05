# main.tf in /modules/compute

resource "aws_security_group" "instance" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "web" {
  ami                    = "ami-03972092c42e8c0ca"
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id_1  # Use the first public subnet
  vpc_security_group_ids = [aws_security_group.instance.id]

  tags = {
    Name = "TerraformExampleInstance"
  }
}

resource "aws_launch_configuration" "app" {
  name          = "app-launch-configuration"
  image_id      = "ami-03972092c42e8c0ca" # Use a valid AMI ID
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app" {
  vpc_zone_identifier    = [var.public_subnet_id_1, var.public_subnet_id_2]  # Specify the subnet IDs
  desired_capacity       = 2
  max_size               = 3
  min_size               = 1
  launch_configuration   = aws_launch_configuration.app.id

  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }
}


output "autoscaling_group_id" {
  value = aws_autoscaling_group.app.id
}

resource "aws_lb_target_group" "app" {
  name     = "app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "app-target-group"
  }
}

resource "aws_lb" "app" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.instance.id]
  subnets            = [var.public_subnet_id_1, var.public_subnet_id_2]  # Two subnets in different AZs

  enable_deletion_protection = false

  tags = {
    Name = "app-load-balancer"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.app.name
  lb_target_group_arn   = aws_lb_target_group.app.arn
}

