resource "aws_route53_record" "landing" {
  zone_id = var.zone_id
  name    = "landing.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.landing.domain_name
    zone_id                = aws_cloudfront_distribution.landing.hosted_zone_id
    evaluate_target_health = false
  }
}