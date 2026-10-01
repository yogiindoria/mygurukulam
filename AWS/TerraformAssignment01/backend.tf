# Pehle S3 bucket manually bana lo (versioning ON), phir terraform init chalao.
terraform {
  backend "s3" {
    bucket       = "ass4-sonarqube-terraform-state"
    key          = "sonarqube/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
