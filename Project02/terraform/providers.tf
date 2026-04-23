provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project   = "DevOps-Project-02"
      ManagedBy = "Terraform"
      Owner     = "Infra_admin"
    }
  }
}