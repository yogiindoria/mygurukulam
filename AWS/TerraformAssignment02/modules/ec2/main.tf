resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = var.bastion_instance_type
  subnet_id              = var.bastion_subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]
  key_name               = var.key_name
  tags                   = { Name = "sonarqube-bastion" }
}
