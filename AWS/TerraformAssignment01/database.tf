resource "aws_db_subnet_group" "sonarqube" {
  name       = "sonarqube-db-subnet-group"
  subnet_ids = [aws_subnet.private_db_a.id, aws_subnet.private_db_b.id]
  tags       = { Name = "sonarqube-db-subnet-group" }
}

resource "aws_db_instance" "sonarqube" {
  identifier             = "sonarqube-db"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp3"
  storage_encrypted      = true
  db_name                = "sonarqube"
  username               = "sonaradmin"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.sonarqube.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false
  skip_final_snapshot    = true
  tags                   = { Name = "sonarqube-db" }
}
