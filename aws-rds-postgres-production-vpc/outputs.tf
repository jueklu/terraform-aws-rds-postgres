# RDS Postgres DNS Endpoints
output "rds_endpoint" {
  value = aws_db_instance.rds_db.endpoint
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