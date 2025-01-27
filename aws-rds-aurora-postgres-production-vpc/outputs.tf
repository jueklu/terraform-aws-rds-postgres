# RDS Aurora Postgres Writer Endpoint
output "aurora_writer_endpoint" {
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

# RDS Aurora Postgres Reader Endpoint
output "aurora_reader_endpoint" {
  value       = aws_rds_cluster.aurora_cluster.reader_endpoint
}

# RDS Aurora Postgres Cluster ID
output "aurora_cluster_id" {
  value       = aws_rds_cluster.aurora_cluster.id
  description = "The ID of the Aurora PostgreSQL cluster"
}


# EC2 Public IPs
output "EC2_Public_IPs" {
  description = "Public IPs of the EC2 instances"
  value       = aws_instance.vm[*].public_ip
}

# EC2 Private IPs
output "EC2_Private_IPs" {
  description = "Private IPs of the EC2 instances"
  value       = aws_instance.vm[*].private_ip
}