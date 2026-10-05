data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.vpc_cidr
  name       = var.vpc_name
}

module "subnet" {
  source               = "./modules/subnet"
  vpc_id               = module.vpc.vpc_id
  availability_zone_a  = var.az_a
  availability_zone_b  = var.az_b
  public_subnet_a_cidr = var.public_subnet_a_cidr
  public_subnet_b_cidr = var.public_subnet_b_cidr
  private_app_a_cidr   = var.private_app_a_cidr
  private_app_b_cidr   = var.private_app_b_cidr
  private_db_a_cidr    = var.private_db_a_cidr
  private_db_b_cidr    = var.private_db_b_cidr
  name_prefix          = var.vpc_name
}

module "nat_gateway" {
  source              = "./modules/nat-gateway"
  public_subnet_id    = module.subnet.public_subnet_a_id
  internet_gateway_id = module.vpc.internet_gateway_id
  name_prefix         = var.vpc_name
}

module "route_table" {
  source                 = "./modules/route-table"
  vpc_id                 = module.vpc.vpc_id
  internet_gateway_id    = module.vpc.internet_gateway_id
  nat_gateway_id         = module.nat_gateway.nat_gateway_id
  public_subnet_ids      = module.subnet.public_subnet_ids
  private_app_subnet_ids = module.subnet.private_app_subnet_ids
  private_db_subnet_ids  = module.subnet.private_db_subnet_ids
  name_prefix            = var.vpc_name
}

module "security_group" {
  source          = "./modules/security-group"
  vpc_id          = module.vpc.vpc_id
  ssh_cidr_blocks = var.ssh_cidr_blocks
}

module "ec2" {
  source                = "./modules/ec2"
  ami_id                = data.aws_ssm_parameter.al2023.value
  key_name              = var.key_pair_name
  bastion_instance_type = var.bastion_instance_type
  bastion_subnet_id     = module.subnet.public_subnet_a_id
  bastion_sg_id         = module.security_group.bastion_sg_id
}

module "target_group" {
  source = "./modules/target-group"
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source            = "./modules/alb"
  public_subnet_ids = module.subnet.public_subnet_ids
  security_group_id = module.security_group.alb_sg_id
  target_group_arn  = module.target_group.target_group_arn
}

module "rds" {
  source            = "./modules/rds"
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  engine_version    = var.db_engine_version
  subnet_ids        = module.subnet.private_db_subnet_ids
  security_group_id = module.security_group.rds_sg_id
}

module "asg" {
  source                 = "./modules/asg"
  ami_id                 = data.aws_ssm_parameter.al2023.value
  instance_type          = var.instance_type
  key_name               = var.key_pair_name
  private_app_subnet_ids = module.subnet.private_app_subnet_ids
  app_sg_id              = module.security_group.app_sg_id
  target_group_arn       = module.target_group.target_group_arn
  db_endpoint            = module.rds.endpoint
  db_name                = var.db_name
  db_username            = var.db_username
  db_password            = var.db_password
}
