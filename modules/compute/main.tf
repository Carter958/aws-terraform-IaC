# Security Group for instances
resource "aws_security_group" "instance" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow access to port 3000 from anywhere
  ingress {
    from_port   = 3000
    to_port     = 3000
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

# Launch Template for EC2 Instances
resource "aws_launch_template" "app" {
  name_prefix   = "app-launch-template"
  image_id      = "ami-03972092c42e8c0ca" # Example AMI ID, change to your region-specific ID
  instance_type = "t2.micro"

  user_data = base64encode(<<EOF
#!/bin/bash
set -x  # Enable shell debugging

# Log the start of the user data script
echo "Starting user data script" >> /var/log/user-data.log

# Install the Amazon CloudWatch Agent
yum install -y amazon-cloudwatch-agent >> /var/log/user-data.log 2>&1
if [ $? -ne 0 ]; then
  echo "CloudWatch Agent installation failed" >> /var/log/user-data.log
  exit 1
fi

# Configure CloudWatch Agent
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

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s >> /var/log/user-data.log 2>&1
if [ $? -ne 0 ]; then
  echo "CloudWatch Agent configuration failed" >> /var/log/user-data.log
  exit 1
fi

# Install the AWS CodeDeploy Agent
yum install -y ruby wget >> /var/log/user-data.log 2>&1
if [ $? -ne 0 ]; then
  echo "Failed to install Ruby or Wget" >> /var/log/user-data.log
  exit 1
fi

cd /home/ec2-user >> /var/log/user-data.log 2>&1
wget https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install >> /var/log/user-data.log 2>&1
if [ $? -ne 0 ]; then
  echo "Failed to download CodeDeploy agent" >> /var/log/user-data.log
  exit 1
fi

chmod +x ./install >> /var/log/user-data.log 2>&1
./install auto >> /var/log/user-data.log 2>&1
if [ $? -ne 0 ]; then
  echo "CodeDeploy Agent installation failed" >> /var/log/user-data.log
  exit 1
fi

service codedeploy-agent start >> /var/log/user-data.log 2>&1
if [ $? -ne 0 ]; then
  echo "Failed to start CodeDeploy agent" >> /var/log/user-data.log
  exit 1
fi

echo "User data script completed successfully" >> /var/log/user-data.log

EOF
  )

  # Attach IAM Instance Profile
  iam_instance_profile {
    name = var.iam_instance_profile
  }

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
  vpc_zone_identifier = [var.public_subnet_id_1, var.public_subnet_id_2]
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
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

# Listener for the Load Balancer
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Attach the Auto Scaling Group to the Load Balancer
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.app.name
  lb_target_group_arn    = aws_lb_target_group.app.arn
}

# Target Tracking Scaling Policy
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                      = "cpu-target-tracking"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 300

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }

  autoscaling_group_name = aws_autoscaling_group.app.name
}
