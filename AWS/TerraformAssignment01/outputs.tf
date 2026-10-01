output "sonarqube_url" {
  value = "http://${aws_lb.sonarqube.dns_name}"
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.sonarqube.address
}

output "vpc_id" {
  value = aws_vpc.main.id
}
