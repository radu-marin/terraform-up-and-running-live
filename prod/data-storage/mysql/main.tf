provider "aws" {
    region = "us-east-2"
}

module "mysql_data" {
  source = "../../../modules/data-storage/mysql"
  #to try and check if it works with github:
  #source = "git::git@github.com:radu-marin/terraform-up-and-running-modules.git?ref=v0.0.1"

  db_name = "prod"
  db_username = "admin"
  db_password = var.db_password
}

# store tf state to the same ol' s3
terraform {
  backend "s3" {
    bucket = "r-terraform-up-and-running-state"
    key = "prod/data-storage/mysql/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "r-terraform-up-and-running-locks"
    encrypt = true
  }
}