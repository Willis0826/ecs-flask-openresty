resource "aws_route53_zone" "willischou" {
  name = "willischou.com."
  comment = "Managed by Terraform"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.willischou.zone_id
  name    = "www.willischou.com."
  type    = "A"

  alias {
    name                   = aws_elb.ecs-openresty.dns_name
    zone_id                = aws_elb.ecs-openresty.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "dev" {
  zone_id = aws_route53_zone.willischou.zone_id
  name    = "dev.willischou.com."
  type    = "A"

  alias {
    name                   = aws_elb.ecs-openresty.dns_name
    zone_id                = aws_elb.ecs-openresty.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "survey" {
  zone_id = aws_route53_zone.willischou.zone_id
  name    = "survey.willischou.com."
  type    = "A"

  alias {
    name                   = aws_elb.ecs-openresty.dns_name
    zone_id                = aws_elb.ecs-openresty.zone_id
    evaluate_target_health = true
  }
}

# internal dns for flask elb
resource "aws_route53_zone" "private" {
  name = "internal.service"

  vpc {
    vpc_id = data.aws_vpc.default.id
  }
}

resource "aws_route53_record" "flask" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "flask.internal.service"
  type    = "A"
  
  alias {
    name                   = aws_alb.ecs-flask.dns_name
    zone_id                = aws_alb.ecs-flask.zone_id
    evaluate_target_health = true
  }
}