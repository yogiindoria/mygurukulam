# ---------------- AMI (Amazon Linux 2023) ----------------
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ---------------- Bastion Host ----------------
resource "aws_instance" "bastion" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.bastion.id]
  tags                   = { Name = "sonarqube-bastion" }
}

# ---------------- Launch Template (SonarQube) ----------------
resource "aws_launch_template" "sonarqube" {
  name_prefix            = "sonarqube-lt-"
  image_id               = data.aws_ssm_parameter.al2023.value
  instance_type          = "c7i-flex.large"
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.app.id]

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp3"
    }
  }

  user_data = base64encode(<<-EOT
    #!/bin/bash
    dnf update -y
    dnf install -y docker
    systemctl enable --now docker

    # SonarQube (Elasticsearch) kernel requirements
    sysctl -w vm.max_map_count=524288
    sysctl -w fs.file-max=131072
    echo "vm.max_map_count=524288" >> /etc/sysctl.conf
    echo "fs.file-max=131072" >> /etc/sysctl.conf

    docker run -d --name sonarqube --restart unless-stopped \
      -p 9000:9000 \
      --ulimit nofile=131072:131072 \
      -e SONAR_JDBC_URL=jdbc:postgresql://${aws_db_instance.sonarqube.address}:5432/sonarqube \
      -e SONAR_JDBC_USERNAME=sonaradmin \
      -e SONAR_JDBC_PASSWORD=${var.db_password} \
      sonarqube:community
  EOT
  )

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "sonarqube-app" }
  }
}

# ---------------- ALB ----------------
resource "aws_lb" "sonarqube" {
  name               = "sonarqube-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  tags               = { Name = "sonarqube-alb" }
}

resource "aws_lb_target_group" "sonarqube" {
  name     = "sonarqube-tg"
  port     = 9000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/api/system/status"
    matcher             = "200"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  tags = { Name = "sonarqube-tg" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.sonarqube.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sonarqube.arn
  }
}

# ---------------- Auto Scaling Group ----------------
# NOTE: SonarQube Community Edition ek hi node support karta hai, isliye 1/1/1.
# ASG ka kaam yahan self-healing hai (instance fail -> naya launch).
resource "aws_autoscaling_group" "sonarqube" {
  name                      = "sonarqube-asg"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.private_app_a.id, aws_subnet.private_app_b.id]
  target_group_arns         = [aws_lb_target_group.sonarqube.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 400

  launch_template {
    id      = aws_launch_template.sonarqube.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "sonarqube-app"
    propagate_at_launch = true
  }

  depends_on = [aws_nat_gateway.nat]
}
