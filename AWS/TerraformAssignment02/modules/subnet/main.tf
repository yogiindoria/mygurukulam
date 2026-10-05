resource "aws_subnet" "public_a" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_a_cidr
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.name_prefix}-public-a" }
}
resource "aws_subnet" "public_b" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_b_cidr
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.name_prefix}-public-b" }
}
resource "aws_subnet" "private_app_a" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_app_a_cidr
  availability_zone = var.availability_zone_a
  tags              = { Name = "${var.name_prefix}-private-app-a" }
}
resource "aws_subnet" "private_app_b" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_app_b_cidr
  availability_zone = var.availability_zone_b
  tags              = { Name = "${var.name_prefix}-private-app-b" }
}
resource "aws_subnet" "private_db_a" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_db_a_cidr
  availability_zone = var.availability_zone_a
  tags              = { Name = "${var.name_prefix}-private-db-a" }
}
resource "aws_subnet" "private_db_b" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_db_b_cidr
  availability_zone = var.availability_zone_b
  tags              = { Name = "${var.name_prefix}-private-db-b" }
}
