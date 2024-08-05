# Security Group for instances
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

# Launch Template for ASG
resource "aws_launch_template" "app" {
  name_prefix   = "app-launch-template"
  image_id      = "ami-03972092c42e8c0ca" # Replace with your AMI ID
  instance_type = "t2.micro"

  user_data = base64encode(<<EOF
#!/bin/bash
yum install -y amazon-cloudwatch-agent
cat <<EOT > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/cloud-init.log",
            "log_group_name": "cloud-init-log-group",
            "log_stream_name": "{instance_id}/cloud-init-log"
          }
        ]
      }
    }
  }
}
EOT
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
EOF
  )

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

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  vpc_zone_identifier    = [var.public_subnet_id_1, var.public_subnet_id_2]
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

# Target Group for the Load Balancer
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

# Load Balancer
resource "aws_lb" "app" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.instance.id]
  subnets            = [var.public_subnet_id_1, var.public_subnet_id_2]

  enable_deletion_protection = false

  tags = {
    Name = "app-load-balancer"
  }
}

# Attach the Auto Scaling Group to the Load Balancer
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
