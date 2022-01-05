# Create a new load balancer
resource "aws_elb" "production" {
  name               = "production"
  subnets = [aws_subnet.public_subnet_01.id,aws_subnet.public_subnet_02.id]
  security_groups = [aws_security_group.production-elb.id]

  
  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/"
    interval            = 30
  }

 
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "production-elb"
  }
}
