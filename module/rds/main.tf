# saedul/module/rds/main.tf

resource "aws_rds_cluster" "aurora-cluster" {
  engine                  = var.db_engine
  engine_mode             = "provisioned"
  engine_version          = var.db_engine_version #  8.0.mysql_aurora.3.02.1 5.7.mysql_aurora.2.07.1
  
  availability_zones      = var.azs
  cluster_identifier      = "${var.env}-aurora-cluster"
  master_username         = "cookalone"
  master_password         = "1qaz#edc"
  database_name           = "cookalone"
  db_subnet_group_name    = aws_db_subnet_group.aurora-subnet-group.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.aurora-cluster-parameter-group.name
  
  backup_retention_period = 7
  skip_final_snapshot     = true
  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "aurora-cluster-instances" {
  identifier         = "${var.env}-cluster-${count.index}-aurora-cluster-instance"
  count              = 2
  cluster_identifier = aws_rds_cluster.aurora-cluster.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora-cluster.engine
  engine_version     = aws_rds_cluster.aurora-cluster.engine_version
  
  publicly_accessible = true
  
}

resource "aws_db_subnet_group" "aurora-subnet-group" {
  name = "${var.env}-aurora-subnet-group"
  subnet_ids = var.private-data-subnets[*]
}

resource "aws_security_group" "aurora-security-group" {
  vpc_id      = var.vpc
  name        = "${var.env}-aurora-security-group"
  description = "aurora security group for mysql"
ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_rds_cluster_parameter_group" "aurora-cluster-parameter-group" {
  name        = "${var.env}-cluster-aurora-parameter-group"
  family      = "aurora-mysql8.0"
  description = "aurora parameter group"

  parameter {
    apply_method = "pending-reboot"
    name  = "lower_case_table_names"
    value = "1"
  }
}