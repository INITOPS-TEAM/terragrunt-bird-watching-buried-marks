resource "aws_route53_record" "birdwatching" {
    zone_id = var.zone_id
    name    = var.domain_name
    type    = "A"
    ttl     = 300
    records = [aws_instance.lb.public_ip]
}