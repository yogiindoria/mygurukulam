variable "my_ip_cidr" {
  description = "Tumhara public IP for SSH to bastion, e.g. 203.0.113.10/32"
  type        = string
}

variable "key_pair_name" {
  description = "Existing EC2 key pair name in ap-south-1"
  type        = string
}

variable "db_password" {
  description = "RDS master password (alphanumeric only, min 12 chars)"
  type        = string
  sensitive   = true
}
