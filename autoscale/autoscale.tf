data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  
}

#ec2 keypair

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgi0ogjGnJno8zou2pk9YuSh5I8KxRFXh4Z0CYrMYph7tmi5Er+pfKOSWblUo/2SolCFgn8p+xg+a6jIac07aWkWi78eajaqIPIZhFxPiWw20v0rjCNdmZB+m9ZOxUNzhsUDkaIxZ+xhKjKNpcxGqqhpLGBOx1ZYAdtG5I+CxX2a+uZV0ixXB+Cd2zCIRg3/lfvsTCx7ERa4rt6pd7ngQZ0fKc6gX7yFnWxPo0qTi64dtD77qeLAUB6n+RYqQnyB6kXn5L+j9L6spK7lfvKoZwtmALAdEVFkGsGw82Bd2yJt61yiocU0TWnY2hYw13IuXg78U+fA3o6w7dFnttfzW7 kuba"
}

#aws_launch_configuration

resource "aws_launch_configuration" "production" {
  name          = "production"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.deployer.key_name}"
  security_groups = [aws_security_group.production-ec2.id]
  
}

#aws_auto_scale_group

resource "aws_autoscaling_group" "production" {
  name                      = "production"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.production.name
  vpc_zone_identifier       = [aws_subnet.public_subnet_01.id,aws_subnet.public_subnet_02.id]

  
  tag {
    key                 = "name"
    value               = "production"
    propagate_at_launch = true
  }
}  


#auto scale cofiguration policy increase

resource "aws_autoscaling_policy" "custome-cpu-policy" {
  name                   = "custome-cpu-policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.production.name
  policy_type            = "SimpleScaling"
}

#cloud watch metric alarm increase

resource "aws_cloudwatch_metric_alarm" "custome-cpu-alarm" {
  alarm_name          = "custome-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.production.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.custome-cpu-policy.arn]
}


#auto scale cofiguration policy descrease

resource "aws_autoscaling_policy" "custome-cpu-policy-descrease" {
  name                   = "custome-cpu-policy-descrease"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.production.name
  policy_type            = "SimpleScaling"
}

#cloud watch metric alarm descrease

resource "aws_cloudwatch_metric_alarm" "custome-cpu-alarm-descrease" {
  alarm_name          = "custome-cpu-alarm-descrease"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.production.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.custome-cpu-policy.arn]
}
