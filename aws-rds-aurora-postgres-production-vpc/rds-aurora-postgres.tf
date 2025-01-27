# Aurora Subnet Group
resource "aws_db_subnet_group" "aurora_subnet_group" {
  provider      = aws.aws_region
  name          = "aurora-main"
  subnet_ids    = [aws_subnet.subnets_private[0].id, aws_subnet.subnets_private[1].id]

  depends_on    = [aws_subnet.subnets_private]

  tags = {
    Name        = "${var.vpc_name} Aurora Subnet Group"
    Env         = "Production"
  }
}

# Aurora Cluster
resource "aws_rds_cluster" "aurora_cluster" {
  provider                = aws.aws_region
  cluster_identifier      = "aurora-postgres-cluster"
  engine                  = "aurora-postgresql"
  engine_version          = "16.6"
  database_name           = "auroradb"
  master_username         = var.postgres_user
  master_password         = var.postgres_pw
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.sg_postgres.id]
  backup_retention_period = 7
  preferred_backup_window = "03:00-04:00"
  availability_zones      = [aws_subnet.subnets_private[0].availability_zone, aws_subnet.subnets_private[1].availability_zone]
  storage_encrypted       = true

  skip_final_snapshot     = true  # Ensure final snapshots are skipped during deletion
  final_snapshot_identifier = null  # Prevent Terraform from expecting a final snapshot identifier

  tags = {
    Name = "${var.vpc_name} Aurora Cluster"
    Env  = "Production"
  }

  depends_on = [aws_db_subnet_group.aurora_subnet_group]
}


## Aurora Instances

# Aurora Writer Instance
resource "aws_rds_cluster_instance" "aurora_writer_instance" {
  provider                = aws.aws_region
  identifier              = "aurora-postgres-writer"
  cluster_identifier      = aws_rds_cluster.aurora_cluster.id
  instance_class          = "db.t3.medium"
  engine                  = "aurora-postgresql"
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name

  tags = {
    Name = "${var.vpc_name} Aurora Writer Instance"
    Env  = "Production"
  }

  depends_on = [aws_rds_cluster.aurora_cluster]
}

# Aurora Reader Instance
resource "aws_rds_cluster_instance" "aurora_reader_instance" {
  provider                = aws.aws_region
  identifier              = "aurora-postgres-reader"
  cluster_identifier      = aws_rds_cluster.aurora_cluster.id
  instance_class          = "db.t3.medium"
  engine                  = "aurora-postgresql"
  publicly_accessible     = false
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name

  tags = {
    Name = "${var.vpc_name} Aurora Reader Instance"
    Env  = "Production"
  }

  depends_on = [aws_rds_cluster.aurora_cluster]
}


# Aurora Security Group
resource "aws_security_group" "sg_postgres" {
  provider      = aws.aws_region
  name          = "SG_Allow_Aurora_Postgres"
  description   = "Allow Aurora Postgres traffic"
  vpc_id        = aws_vpc.vpc.id

  ingress {
    description = "Allow Aurora Postgres from EC2 instances"
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
    Name = "${var.vpc_name} Aurora Postgres SG"
    Env  = "Production"
  }
}