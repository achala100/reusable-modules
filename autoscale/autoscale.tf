data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }
  
}

#aws_launch_configuration

resource "aws_launch_configuration" "production" {
  name          = "production"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  
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
  vpc_zone_identifier       = ["subnet-06708642c2900872c"]

  
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
