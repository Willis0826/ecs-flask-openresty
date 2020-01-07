# elb for openresty
resource "aws_elb" "ecs-openresty" {
  name               = "ecs-openresty"
  subnets         = ["${data.aws_subnet.us-east-2a.id}", "${data.aws_subnet.us-east-2b.id}"]
  security_groups = ["${aws_security_group.openresty-elb-sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags = {
    Name = "ecs-openresty"
  }
}
