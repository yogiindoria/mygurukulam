# ---------------- ALB SG ----------------
resource "aws_security_group" "alb" {
  name        = "sonarqube-alb-sg"
  description = "Allow HTTP from internet to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sonarqube-alb-sg" }
}

# ---------------- Bastion SG ----------------
resource "aws_security_group" "bastion" {
  name        = "sonarqube-bastion-sg"
  description = "SSH from my IP only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sonarqube-bastion-sg" }
}

# ---------------- App (SonarQube) SG ----------------
resource "aws_security_group" "app" {
  name        = "sonarqube-app-sg"
  description = "SonarQube instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SonarQube port from ALB"
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sonarqube-app-sg" }
}

# ---------------- RDS SG ----------------
resource "aws_security_group" "rds" {
  name        = "sonarqube-rds-sg"
  description = "PostgreSQL from app instances only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from app SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  tags = { Name = "sonarqube-rds-sg" }
}
