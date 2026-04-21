output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_id" {
  value = aws_subnet.public[var.nat_az].id
}

output "compute_subnet_id" {
  value = aws_subnet.compute[var.nat_az].id
}

output "compute_subnet_ids" {
  value = [for s in aws_subnet.compute : s.id]
}

output "eks_subnet_ids" {
  value = [for s in aws_subnet.eks : s.id]
}

output "nat_gateway_ip" {
  description = "Public IP of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}
