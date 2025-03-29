resource "aws_db_subnet_group" "main" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "rds" {
  name   = "${var.identifier}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_kms_key" "rds" {
  description = "KMS key for RDS encryption"
}

resource "aws_db_instance" "main" {
  identifier           = var.identifier
  allocated_storage    = 20
  storage_type        = "gp2"
  engine              = "postgres"
  engine_version      = "14"
  instance_class      = var.instance_class
  db_name             = var.database_name
  username            = var.master_username
  password            = var.master_password
  skip_final_snapshot = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  storage_encrypted = true
  kms_key_id       = aws_kms_key.rds.arn
}