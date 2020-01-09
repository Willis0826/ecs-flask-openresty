resource "aws_route53_zone" "willischou" {
  name = "willischou.com."
  comment = "Managed by Terraform"
}

resource "aws_route53_record" "www" {
  zone_id = "${aws_route53_zone.willischou.zone_id}"
  name    = "www.willischou.com."
  type    = "A"

  alias {
    name                   = "${aws_elb.ecs-openresty.dns_name}"
    zone_id                = "${aws_elb.ecs-openresty.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "dev" {
  zone_id = "${aws_route53_zone.willischou.zone_id}"
  name    = "dev.willischou.com."
  type    = "A"

  alias {
    name                   = "${aws_elb.ecs-openresty.dns_name}"
    zone_id                = "${aws_elb.ecs-openresty.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "survey" {
  zone_id = "${aws_route53_zone.willischou.zone_id}"
  name    = "survey.willischou.com."
  type    = "A"

  alias {
    name                   = "${aws_elb.ecs-openresty.dns_name}"
    zone_id                = "${aws_elb.ecs-openresty.zone_id}"
    evaluate_target_health = true
  }
}
