resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.env}-db-subnet-group"
  subnet_ids = var.compute_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.env}-db-subnet-group"
  })
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.env}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.env}-rds-sg"
  })
}

# RDS Security Group Rules
resource "aws_vpc_security_group_ingress_rule" "rds_postgres_from_eks" {
  security_group_id = aws_security_group.rds.id
  for_each          = var.compute_subnets
  cidr_ipv4         = each.value
  from_port         = 5432
  to_port           = 5432
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "rds_mariadb_from_eks" {
  security_group_id = aws_security_group.rds.id
  for_each          = var.compute_subnets
  cidr_ipv4         = each.value
  from_port         = 3306
  to_port           = 3306
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "rds_egress" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  to_port           = 65535
  ip_protocol       = "tcp"
}


# Postgres instance for the Auth service and voting service,
resource "aws_db_instance" "auth" {
  identifier                          = "${var.app2}-${var.env}-auth-db"
  engine                              = "postgres"
  engine_version                      = local.postg_eng_v
  allow_major_version_upgrade         = true
  apply_immediately                   = true
  iam_database_authentication_enabled = true

  db_name  = local.auth_secret["DB_NAME"]
  username = local.auth_secret["DB_USER"]
  password = local.auth_secret["DB_PASSWORD"]

  instance_class            = local.db_defaults.instance_class
  allocated_storage         = local.db_defaults.allocated_storage
  db_subnet_group_name      = aws_db_subnet_group.this.name
  vpc_security_group_ids    = [aws_security_group.rds.id]
  skip_final_snapshot       = local.db_defaults.skip_final_snapshot
  final_snapshot_identifier = "${var.app2}-${var.env}-auth-and-voting-db"

  tags = merge(local.common_tags, {
    Name = "${var.app2}-${var.env}-auth-db"
  })
}

# Separate instance for MariaDB (map service)
resource "aws_db_instance" "map" {
  identifier                          = "${var.app2}-${var.env}-map-db"
  engine                              = "mariadb"
  engine_version                      = local.mar_eng_v
  allow_major_version_upgrade         = true
  apply_immediately                   = true
  iam_database_authentication_enabled = true

  db_name  = local.map_secret["MARIADB_DATABASE"]
  username = local.map_secret["MARIADB_USER"]
  password = local.map_secret["MARIADB_PASSWORD"]

  instance_class            = local.db_defaults.instance_class
  allocated_storage         = local.db_defaults.allocated_storage
  db_subnet_group_name      = aws_db_subnet_group.this.name
  vpc_security_group_ids    = [aws_security_group.rds.id]
  skip_final_snapshot       = local.db_defaults.skip_final_snapshot
  final_snapshot_identifier = "${var.app2}-${var.env}-map-db"

  tags = merge(local.common_tags, {
    Name = "${var.app2}-${var.env}-map-db"
  })
}
