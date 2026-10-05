
locals {
  user_data = <<-EOF
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
      -e SONAR_JDBC_URL=jdbc:postgresql://${var.db_endpoint}:5432/${var.db_name} \
      -e SONAR_JDBC_USERNAME=${var.db_username} \
      -e SONAR_JDBC_PASSWORD=${var.db_password} \
      sonarqube:community
  EOF
}

resource "aws_launch_template" "this" {
  name_prefix            = "sonarqube-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [var.app_sg_id]
  user_data              = base64encode(local.user_data)
  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "sonarqube-app" }
  }
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 30
      volume_type = "gp3"
    }
  }
}
resource "aws_autoscaling_group" "this" {
  name                = "sonarqube-asg"
  min_size            = 1
  max_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = var.private_app_subnet_ids
  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
  target_group_arns         = [var.target_group_arn]
  health_check_type         = "ELB"
  health_check_grace_period = 400
  tag {
    key                 = "Name"
    value               = "sonarqube-app"
    propagate_at_launch = true
  }
}
