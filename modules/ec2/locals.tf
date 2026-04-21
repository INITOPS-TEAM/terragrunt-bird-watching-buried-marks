locals {
  consul-port = {
    rpc      = { port = 8300, protocol = "tcp" }
    serf_tcp = { port = 8301, protocol = "tcp" }
    serf_udp = { port = 8301, protocol = "udp" }
    dns_tcp  = { port = 8600, protocol = "tcp" }
    dns_udp  = { port = 8600, protocol = "udp" }
  }
  security_groups_with_internet = {
    app    = aws_security_group.app.id
    lb     = aws_security_group.lbnginx.id
    consul = aws_security_group.consul.id
    ssh    = aws_security_group.ssh.id
  }
}
