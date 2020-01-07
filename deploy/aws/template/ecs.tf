# flask
## ecs cluster
### ecs resource
resource "aws_ecs_cluster" "flask" {
  name = "flask"
}

resource "aws_ecs_task_definition" "flask" {
  family                = "flask"
  container_definitions = "${file("task-definitions-flask.json")}"
}

resource "aws_ecs_service" "flask" {
  name            = "flask"
  cluster         = "${aws_ecs_cluster.flask.id}"
  task_definition = "${aws_ecs_task_definition.flask.arn}"
  desired_count   = 1

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.ecs-flask.arn}"
    container_name   = "flask"
    container_port   = 5000
  }

  depends_on = [
      "aws_alb_listener.flask",
  ]
}

### compute resources
data "aws_ami" "stable-coreos" {
  most_recent = true

  filter {
    name   = "description"
    values = ["CoreOS Container Linux stable *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["595879546273"] # CoreOS
}

data "template_file" "cloud_config" {
  template = "${file("cloud-config.yaml")}"

  vars = {
    aws_region         = "{{.Env.AWS_DEFAULT_REGION}}"
    ecs_cluster_name   = "${aws_ecs_cluster.flask.name}"
    ecs_log_level      = "info"
    ecs_agent_version  = "latest"
  }
}


resource "aws_iam_instance_profile" "ecs" {
  name = "ecs-instprofile"
  role = "${aws_iam_role.ecs-instance.name}"
}

resource "aws_iam_role" "ecs-instance" {
  name = "ecs-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "instance" {
  name   = "TfEcsExampleInstanceRole"
  role   = "${aws_iam_role.ecs-instance.name}"
  policy = "${file("instance-profile-policy.json")}"
}

resource "aws_launch_configuration" "flask" {
  security_groups = [
    "${aws_security_group.instance-sg.id}",
  ]

  key_name                    = "ecs-flask-cluster" # FIXME using terraform to create key pair
  image_id                    = "${data.aws_ami.stable-coreos.id}"
  instance_type               = "t2.small"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs.name}"
  user_data                   = "${data.template_file.cloud_config.rendered}"
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "flask" {
  name                 = "flask"
  vpc_zone_identifier  = ["${data.aws_subnet.us-east-2a.id}", "${data.aws_subnet.us-east-2b.id}"]
  min_size             = 1
  max_size             = 2
  desired_capacity     = 1
  launch_configuration = "${aws_launch_configuration.flask.name}"

  tags = [
    {
      key                 = "Name"
      value               = "ecs-flask"
      propagate_at_launch = true
    },
    {
      key                 = "env"
      value               = "{{.Env.DEPLOY_ENV}}"
      propagate_at_launch = true
    },
  ]
}

# openresty
## openresty cluster
### ecs resource
resource "aws_ecs_cluster" "openresty" {
  name = "openresty"
}

resource "aws_ecs_task_definition" "openresty" {
  family                = "openresty"
  container_definitions = "${file("task-definitions-openresty.json")}"
}

resource "aws_ecs_service" "openresty" {
  name            = "openresty"
  cluster         = "${aws_ecs_cluster.openresty.id}"
  task_definition = "${aws_ecs_task_definition.openresty.arn}"
  desired_count   = 1

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    # target_group_arn = "${aws_alb_target_group.ecs-flask.arn}"
    container_name   = "openresty"
    container_port   = 5000
  }

  depends_on = [
      # "aws_alb_listener.flask",
  ]
}

### compute resources