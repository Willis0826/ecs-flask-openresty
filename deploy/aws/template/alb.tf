# alb for flask
resource "aws_alb_target_group" "ecs-flask" {
  name     = "ecs-flask"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = "${data.aws_vpc.default.id}"
}

resource "aws_alb" "ecs-flask" {
  name            = "alb-ecs"
  subnets         = ["${data.aws_subnet.us-east-2a.id}", "${data.aws_subnet.us-east-2b.id}"]
  security_groups = ["${aws_security_group.flask-alb-sg.id}"]
}

resource "aws_alb_listener" "flask" {
  load_balancer_arn = "${aws_alb.ecs-flask.id}"
  port              = "5000"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.ecs-flask.id}"
    type             = "forward"
  }
}
