terraform {
  backend "s3" {
    bucket         = "ass4-sonarqube-terraform-state"
    key            = "assignment-05/sonarqube/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    use_lockfile   = true
    dynamodb_table = "ass5-sonarqube-terraform-lock"
  }
}