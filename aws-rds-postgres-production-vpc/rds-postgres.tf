# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  provider      = aws.aws_region
  name          = "main"
  subnet_ids    = [aws_subnet.subnets_private[0].id, aws_subnet.subnets_private[1].id]

  depends_on = [aws_subnet.subnets_private]

  tags = {
    Name        = "${var.vpc_name} RDS Subnet Group"
    Env         = "Production"
  }
}

# RDS PostgreSQL
resource "aws_db_instance" "rds_db" {
  provider                = aws.aws_region
  allocated_storage       = 10
  identifier              = "postgres-test2"
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.id
  engine                  = "postgres"
  engine_version          = "14"
  instance_class          = "db.t3.micro"
  username                = var.postgres_user
  password                = var.postgres_pw
  vpc_security_group_ids  = [aws_security_group.sg_postgres.id]
  skip_final_snapshot     = true
  multi_az                = true  # Enables Multi-AZ for HA

  depends_on = [aws_db_subnet_group.rds_subnet_group]
}

# RDS Security Group
resource "aws_security_group" "sg_postgres" {
  provider      = aws.aws_region
  name          = "SG_Allow_Postgres"
  description   = "Allow Postgres traffic"
  vpc_id        = aws_vpc.vpc.id

  ingress {
    description = "Allow Postgres from EC2 instances"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_ec2.id] # EC2 security group
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  depends_on = [aws_vpc.vpc]

  tags = {
    Name = "${var.vpc_name} RDS Postgres"
    Env  = "Production"
  }
}