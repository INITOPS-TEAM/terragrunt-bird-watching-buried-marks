resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.project_name}-${var.env}-vpc"
  }
}
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project_name}-${var.env}-igw"
  }
}
#Subnet public
resource "aws_subnet" "public" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = {
    Name                     = "${var.project_name}-${var.env}-public-${each.key}"
    "kubernetes.io/role/elb" = "1"
  }
}
#Subnet private
resource "aws_subnet" "compute" {
  for_each          = var.compute_subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key
  tags = {
    Name = "${var.project_name}-${var.env}-compute-${each.key}"
  }
}
resource "aws_subnet" "eks" {
  for_each          = var.eks_subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key
  tags = {
    Name                                        = "${var.project_name}-${var.env}-eks-${each.key}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}
# NAT
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.project_name}-${var.env}-nat-eip" }
}
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[var.nat_az].id
  tags = {
    Name = "${var.project_name}-${var.env}-nat-gw"
  }
  depends_on = [aws_internet_gateway.this]
}
#Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.project_name}-${var.env}-rt-public" }
}
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.project_name}-${var.env}-rt-private" }
}
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}
#Associations
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "compute" {
  for_each       = aws_subnet.compute
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "eks" {
  for_each       = aws_subnet.eks
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
