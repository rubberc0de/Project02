terraform {
  backend "s3" {
    bucket         = "bucket-tfstate-devops"
    key            = "proyectos/DevOps_Project02/terraform.tfstate"
    region         = "eu-south-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

resource "aws_dynamodb_table" "terraformlocktable" {
    name         = "terraform-lock-table"
    region       = "eu-south-2"
    read_capacity  = 5
    write_capacity = 5
    hash_key       = "LockID"
    
attribute {
    name = "LockID"
    type = "S"
  }
}