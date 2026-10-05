variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "sonarqube-vpc"
}

variable "az_a" {
  type    = string
  default = "ap-south-1a"
}

variable "az_b" {
  type    = string
  default = "ap-south-1b"
}

variable "public_subnet_a_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "public_subnet_b_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "private_app_a_cidr" {
  type    = string
  default = "10.0.11.0/24"
}

variable "private_app_b_cidr" {
  type    = string
  default = "10.0.12.0/24"
}

variable "private_db_a_cidr" {
  type    = string
  default = "10.0.21.0/24"
}

variable "private_db_b_cidr" {
  type    = string
  default = "10.0.22.0/24"
}

variable "key_pair_name" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "bastion_instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ssh_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "db_name" {
  type    = string
  default = "sonarqube"
}

variable "db_username" {
  type    = string
  default = "sonaradmin"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "db_engine_version" {
  type    = string
  default = "15"
}