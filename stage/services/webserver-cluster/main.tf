provider "aws" {
  region = "us-east-2"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"
  #to try and check if it works with github:
  #source = "git::git@github.com:radu-marin/terraform-up-and-running-modules.git?ref=v0.0.1"

  cluster_name = "webservers-stage"
  instance_type = "t2.micro"
  min_size = 2
  max_size = 3

  db_remote_state_bucket = "r-terraform-up-and-running-state"
  db_remote_state_key = "stage/data-storage/mysql/terraform.tfstate"
}

# Custom security group rule example for staging, exposing an extra port just for testing
resource "aws_security_group_rule" "allow_testing" {
  type = "ingress"
  security_group_id = module.webserver_cluster.alb_security_group_id

  from_port = 12345
  to_port = 12345
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

terraform {
  backend "s3"{
    bucket = "r-terraform-up-and-running-state"
    key = "stage/services/webserver-cluster/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "r-terraform-up-and-running-locks"
    encrypt = true
  }
}