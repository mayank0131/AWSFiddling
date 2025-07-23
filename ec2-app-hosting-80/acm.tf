resource "aws_acm_certificate" "test_cert" {
  domain_name       = var.domain
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "test_cert" {
  certificate_arn         = aws_acm_certificate.test_cert.arn
  validation_record_fqdns = values(aws_route53_record.test_cert_validation)[*].fqdn
}