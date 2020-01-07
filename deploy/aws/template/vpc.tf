# default vpc
data "aws_vpc" "default" {
  id = "vpc-6423c80d"
}

data "aws_subnet" "us-east-2a" {
  vpc_id = "${data.aws_vpc.default.id}"
  id = "subnet-a0f203c9"
}

data "aws_subnet" "us-east-2b" {
  vpc_id = "${data.aws_vpc.default.id}"
  id = "subnet-aa858dd2"
}

resource "aws_security_group" "flask-alb-sg" {
  description = "controls access to the ALB"

  vpc_id = "${data.aws_vpc.default.id}"
  name   = "flask-alb-sg"

  ingress {
    protocol    = "tcp"
    from_port   = 5000
    to_port     = 5000
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group" "openresty-elb-sg" {
  description = "controls access to the ELB"

  vpc_id = "${data.aws_vpc.default.id}"
  name   = "openresty-elb-sg"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group" "instance-sg" {
  description = "controls direct access to application instances"
  vpc_id      = "${data.aws_vpc.default.id}"
  name        = "tf-ecs-instsg"

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = [
      "61.219.173.55/32", // office ip
      "210.242.90.193/32", // office ip
    ]
  }

  ingress {
    protocol  = "tcp"
    from_port = 5000
    to_port   = 5000

    cidr_blocks = [
      "61.219.173.55/32", // office ip
      "210.242.90.193/32", // office ip
    ]
  }

  ingress {
    protocol  = "tcp"
    from_port = 5000
    to_port   = 5000

    security_groups = [
      "${aws_security_group.flask-alb-sg.id}",
    ]
  }

  ingress {
    protocol  = "tcp"
    from_port = 32768
    to_port   = 61000

    security_groups = [
      "${aws_security_group.flask-alb-sg.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "openresty-instance-sg" {
  description = "controls direct access to application instances"
  vpc_id      = "${data.aws_vpc.default.id}"
  name        = "openresty-tf-ecs-instsg"

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = [
      "61.219.173.55/32", // office ip
      "210.242.90.193/32", // office ip
    ]
  }

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80

    cidr_blocks = [
      "61.219.173.55/32", // office ip
      "210.242.90.193/32", // office ip
    ]
  }

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80

    security_groups = [
      "${aws_security_group.openresty-elb-sg.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
