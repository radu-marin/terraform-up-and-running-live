provider "aws" {
  region = "us-east-2"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"
  #to try and check if it works with github:
  #source = "git::git@github.com:radu-marin/terraform-up-and-running-modules.git?ref=v0.0.1"

  cluster_name = "webservers-prod"
  instance_type = "t2.micro"
  min_size = 2
  max_size = 4

  db_remote_state_bucket = "r-terraform-up-and-running-state"
  db_remote_state_key = "prod/data-storage/mysql/terraform.tfstate"
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  autoscaling_group_name = module.webserver_cluster.asg_name  #from module outputs.tf
  scheduled_action_name = "scale-out-during-business-hours"
  min_size = 2
  max_size = 5
  desired_capacity = 5
  recurrence = "0 9 * * *"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  autoscaling_group_name = module.webserver_cluster.asg_name #from module outputs.tf
  scheduled_action_name = "scale-in-at-night"
  min_size = 2
  max_size = 5
  desired_capacity = 2
  recurrence = "0 17 * * *"  
}

terraform {
  backend "s3"{
    bucket = "r-terraform-up-and-running-state"
    key = "prod/services/webserver-cluster/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "r-terraform-up-and-running-locks"
    encrypt = true
  }
}