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

resource "aws_launch_template" "app" {
  name_prefix   = "app-launch-template"
  image_id      = "ami-03972092c42e8c0ca" # Linux 2
  instance_type = "t2.micro"

  network_interfaces {
    security_groups = [aws_security_group.instance.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-instance"
    }
  }
}

resource "aws_autoscaling_group" "app" {
  vpc_zone_identifier    = [var.public_subnet_id_1, var.public_subnet_id_2]  # Specify the subnet IDs
  desired_capacity       = 2
  max_size               = 3
  min_size               = 1
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "app-instance"
    propagate_at_launch = true
  }
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
  lb_target_group_arn    = aws_lb_target_group.app.arn
}

# Target Tracking Scaling Policy
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "cpu-target-tracking"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 300

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }

  autoscaling_group_name = aws_autoscaling_group.app.name
}