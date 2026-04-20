# Security Groups
resource "aws_security_group" "ssh" {
  name        = "${var.project_name}-${var.env}-ssh-sg"
  description = "Security group for SSH access"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.project_name}-${var.env}-ssh-sg" }
}

resource "aws_security_group" "lbnginx" {
  name   = "${var.project_name}-${var.env}-lbnginx-sg"
  vpc_id = var.vpc_id
  tags   = { Name = "${var.project_name}-${var.env}-lbnginx-sg" }
}

resource "aws_security_group" "app" {
  name   = "${var.project_name}-${var.env}-app-sg"
  vpc_id = var.vpc_id
  tags   = { Name = "${var.project_name}-${var.env}-app-sg" }
}

resource "aws_security_group" "db" {
  name   = "${var.project_name}-${var.env}-db-sg"
  vpc_id = var.vpc_id
  tags   = { Name = "${var.project_name}-${var.env}-db-sg" }
}

resource "aws_security_group" "consul" {
  name        = "${var.project_name}-${var.env}-consul-sg"
  description = "Security group for Consul cluster and agents"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.project_name}-${var.env}-consul-sg" }
}

# Rules
# SSH only from Jenkins
resource "aws_vpc_security_group_ingress_rule" "ssh_from_jenkins" {
  security_group_id            = aws_security_group.ssh.id
  referenced_security_group_id = var.jenkins_sg_id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

# Internet access for instances
resource "aws_vpc_security_group_egress_rule" "allow_outbound" {
  for_each = local.security_groups_with_internet

  security_group_id = each.value
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# The balancer is available to everyone on port 80 and 443
resource "aws_vpc_security_group_ingress_rule" "lbnginx_80_443" {
  security_group_id = aws_security_group.lbnginx.id
  for_each          = toset(["80", "443"])
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = each.value
  to_port           = each.value
  ip_protocol       = "tcp"
  description       = "Ingress HTTP/HTTPS from all"
  tags              = { Name = "${var.project_name}-${var.env}-nginx-${each.value}" }
}

# Traffic from LB to App
resource "aws_vpc_security_group_ingress_rule" "app_from_lb" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.lbnginx.id
  from_port                    = 5000
  to_port                      = 5000
  ip_protocol                  = "tcp"
}

# Traffic from App to DB
resource "aws_vpc_security_group_ingress_rule" "db_from_app" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

# Consul internal traffic (Server and Agents communication)
resource "aws_vpc_security_group_ingress_rule" "consul_internal" {
  for_each = local.consul-port

  security_group_id            = aws_security_group.consul.id
  referenced_security_group_id = aws_security_group.consul.id
  from_port                    = each.value.port
  to_port                      = each.value.port
  ip_protocol                  = each.value.protocol
  description                  = "Consul ${each.key}"
  tags                         = { Name = "${var.project_name}-${var.env}-consul-${each.key}" }
}

# Consul UI access only from internal network
resource "aws_vpc_security_group_ingress_rule" "consul_tcp_8500" {
  security_group_id = aws_security_group.consul.id
  cidr_ipv4         = var.vpc_cidr
  from_port         = 8500
  to_port           = 8500
  ip_protocol       = "tcp"
  tags              = { Name = "${var.project_name}-${var.env}-consul-tcp-8500" }
}
