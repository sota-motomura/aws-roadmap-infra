resource "aws_db_subnet_group" "main" {
  name       = "phase1-db-subnet-group"
  subnet_ids = [aws_subnet.data_1a.id, aws_subnet.data_1c.id]

  tags = { Name = "phase1-db-subnet-group" }
}

resource "aws_db_instance" "main" {
  identifier             = "phase1-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "phase1db"
  username               = "admin"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]
  multi_az               = false
  skip_final_snapshot    = true
  publicly_accessible    = false

  tags = { Name = "phase1-db" }
}