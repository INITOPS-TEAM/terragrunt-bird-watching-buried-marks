output "host_postgres_rds" {
  value       = aws_db_instance.auth.address
  description = "Host name for auth/voting RDS"
}

output "host_mariadb_rds" {
  value       = aws_db_instance.map.address
  description = "Host name for map RDS"
}

output "rds_map_resource_id" {
  value       = aws_db_instance.map.resource_id
  description = "The RDS Resource ID of map instance"
}

output "rds_auth_resource_id" {
  value       = aws_db_instance.auth.resource_id
  description = "The RDS Resource ID of auth instance"
}

output "auth_db_endpoint" {
  value       = aws_db_instance.auth.endpoint
  description = "The RDS Endpoint of auth RDS"
}

output "map_db_endpoint" {
  value       = aws_db_instance.map.endpoint
  description = "The RDS Endpoint of map RDS"
}
