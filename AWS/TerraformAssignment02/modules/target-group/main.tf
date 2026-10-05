resource "aws_lb_target_group" "this" {
  name     = "sonarqube-tg"
  port     = 9000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled             = true
    path                = "/api/system/status"
    protocol            = "HTTP"
    port                = "9000"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 10
    interval            = 30
    matcher             = "200"
  }
  tags = { Name = "sonarqube-tg" }
}
