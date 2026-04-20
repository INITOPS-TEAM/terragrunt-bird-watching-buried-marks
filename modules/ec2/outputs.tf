output "lb_public_ip" {
  value = aws_instance.lb.public_ip
}

output "consul_sg_id" {
  value = aws_security_group.consul.id
}
