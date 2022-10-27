
resource "aws_rds_cluster" "aurora-cluster" {
  engine                  = "aurora-mysql"
  engine_mode             = "provisioned"
  engine_version          = "8.0.mysql_aurora.3.02.1"
  availability_zones      = local.azs
  cluster_identifier      = "${local.cluster_name}-aurora-cluster"
  master_username         = "cookalone"
  master_password         = "1qaz#edc"
  
  db_subnet_group_name    = aws_db_subnet_group.aurora-subnet-group.name
  
  backup_retention_period = 7
  skip_final_snapshot     = true
}

resource "aws_rds_cluster_instance" "aurora-cluster-instances" {
  identifier         = "${local.cluster_name}-${count.index}-aurora-cluster-instance"
  count              = 2
  cluster_identifier = aws_rds_cluster.aurora-cluster.id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.aurora-cluster.engine
  engine_version     = aws_rds_cluster.aurora-cluster.engine_version
  
  publicly_accessible = false
}

resource "aws_db_subnet_group" "aurora-subnet-group" {
  name = "${local.cluster_name}-aurora-subnet-group"
  subnet_ids = aws_subnet.private-data-subnet.*.id[*]
}

resource "aws_security_group" "aurora-security-group" {
  vpc_id      = aws_vpc.main-vpc.id
  name        = "${local.cluster_name}-aurora-security-group"
  description = "Allow all inbound for mysql"
ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
