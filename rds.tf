resource "aws_rds_cluster" "aurora_cluster" {
  depends_on = [
    aws_security_group.doohp-db-sg
  ]

  availability_zones           = local.availability_zones
  cluster_identifier           = "${var.environment}-aurora-cluster"
  database_name                = var.db_name
  engine                       = "aurora-mysql"
  engine_version               = "5.7.mysql_aurora.2.07.2"
  master_username              = local.db_creds.username
  master_password              = local.db_creds.password
  backup_retention_period      = 14
  preferred_backup_window      = "02:00-03:00"
  preferred_maintenance_window = "wed:03:00-wed:04:00"
  db_subnet_group_name         = aws_db_subnet_group.aurora_subnet_group.name
  final_snapshot_identifier    = "${var.environment}-aurora-cluster"
  vpc_security_group_ids       = [aws_security_group.doohp-db-sg.id]

  tags = {
    Name        = "dohp-${var.environment}-db"
    VPC         = module.vpc.vpc_id
    ManagedBy   = "terraform"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {

  count = var.db_instance_count

  identifier           = "${var.environment}-aurora-instance-${count.index}"
  engine               = "aurora-mysql"
  engine_version       = "5.7.mysql_aurora.2.07.2"
  cluster_identifier   = aws_rds_cluster.aurora_cluster.id
  instance_class       = "db.t2.small"
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
  publicly_accessible  = false

  tags = {
    Name        = "dohp-${var.environment}-db-instance"
    VPC         = module.vpc.vpc_id
    ManagedBy   = "terraform"
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [engine_version]
  }

}

resource "aws_db_subnet_group" "aurora_subnet_group" {

  name        = "${var.environment}_aurora_db_subnet_group"
  description = "Allowed subnets for Aurora DB cluster instances"
  subnet_ids  = module.vpc.private_subnets

  tags = {
    Name        = "${var.environment}-Aurora-DB-Subnet-Group"
    VPC         = module.vpc.vpc_id
    ManagedBy   = "terraform"
    Environment = "${var.environment}"
  }

}


