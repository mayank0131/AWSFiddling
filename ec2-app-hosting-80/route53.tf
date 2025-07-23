resource "aws_route53_zone" "test" {
  name = var.domain
}

resource "aws_route53_record" "alb_alias" {
  zone_id = aws_route53_zone.test.zone_id
  name    = var.domain
  type    = "A"
  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "test_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.test_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  name    = each.value.name
  zone_id = aws_route53_zone.test.zone_id
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}