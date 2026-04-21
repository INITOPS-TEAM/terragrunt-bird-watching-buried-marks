resource "aws_acm_certificate" "marks" {
  domain_name               = "marks.${var.domain_name}"
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "marks_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.marks.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  allow_overwrite = true
  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "marks" {
  certificate_arn         = aws_acm_certificate.marks.arn
  validation_record_fqdns = [for r in aws_route53_record.marks_acm_validation : r.fqdn]
}

output "acm_certificate_arn" {
  value = aws_acm_certificate_validation.marks.certificate_arn
}
