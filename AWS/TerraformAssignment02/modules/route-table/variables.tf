variable "vpc_id" { type = string }
variable "internet_gateway_id" { type = string }
variable "nat_gateway_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_app_subnet_ids" { type = list(string) }
variable "private_db_subnet_ids" { type = list(string) }
variable "name_prefix" { type = string }
