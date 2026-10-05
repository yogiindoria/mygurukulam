variable "ami_id" { type = string }
variable "instance_type" { type = string }
variable "key_name" { type = string }
variable "private_app_subnet_ids" { type = list(string) }
variable "app_sg_id" { type = string }
variable "target_group_arn" { type = string }
variable "db_endpoint" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}