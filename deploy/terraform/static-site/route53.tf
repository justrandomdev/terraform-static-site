locals {
  # cert_sans = ["www.${var.domain_name}", "cdn.${var.domain_name}", "*.${var.domain_name}"]
  cert_sans = ["*.${var.domain_name}"]
}

resource "aws_route53_zone" "primary" {
  name = var.domain_name
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name = var.domain_name
  type = "A"
  alias {
    name = aws_cloudfront_distribution.prod_distribution.domain_name
    zone_id = aws_cloudfront_distribution.prod_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cert_validation" {
  count = length(local.cert_sans) + 1
  name = element(aws_acm_certificate.cert.domain_validation_options.*.resource_record_name, count.index)
  type = element(aws_acm_certificate.cert.domain_validation_options.*.resource_record_type, count.index)
  zone_id = aws_route53_zone.primary.zone_id
  records = [element(aws_acm_certificate.cert.domain_validation_options.*.resource_record_value, count.index)]
  ttl = 60
}