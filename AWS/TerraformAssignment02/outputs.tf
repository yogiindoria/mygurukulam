output "vpc_id" { value = module.vpc.vpc_id }
output "public_subnet_ids" { value = module.subnet.public_subnet_ids }
output "private_app_subnet_ids" { value = module.subnet.private_app_subnet_ids }
output "private_db_subnet_ids" { value = module.subnet.private_db_subnet_ids }
output "bastion_public_ip" { value = module.ec2.bastion_public_ip }
output "alb_dns_name" { value = module.alb.alb_dns_name }
output "rds_endpoint" { value = module.rds.endpoint }
