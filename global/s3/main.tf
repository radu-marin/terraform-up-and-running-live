provider "aws" {
    region = "us-east-2"
}

resource "aws_s3_bucket" "terraform_state" {
    bucket = "r-terraform-up-and-running-state"

    # Prevent accidental deletion of this S3 bucket
    lifecycle {
      prevent_destroy = true # terraform destroy -> will exit with an error
    }

    # DEPRECATED
    # Enable versioning so we can see the full revision history of our 
    # state files (every update to a file actually creates a new version)
    # versioning {
    #   enabled = true
    # }

    #DEPRECATED
    # Enable server-side encryption by default
    # server_side_encryption_configuration {
    #   rule {
    #     apply_server_side_encryption_by_default {
    #         sse_algorithm = "AES256"
    #     }
    #   }
    # }
}

# alternativa lifecycle prevent_destroy
# resource "aws_s3_bucket_lifecycle_configuration" "terraform_state_lifecycle" {
#     bucket = aws_s3_bucket.terraform_state.id
# }

# alternativa deprecated versioning
# Enable versioning so we can see the full revision history of our 
# state files (every update to a file actually creates a new version)
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# alternativa deprecated sever_side_encryption 
# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_sse" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}



# OBS: if someone else is already running "terraform apply" 
# they will have the lock and we must wait.
# => Create a DynamoDB table to use for locking. 
# (supports supports strongly-consistent reads and conditional writes) 
# It must have a primary key called LockID (exact spelling and capitalization!)
resource "aws_dynamodb_table" "terraform_locks" {
    name = "r-terraform-up-and-running-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"
  
    attribute {
      name = "LockID"
      type = "S"
    }
}

# Terraform state is still stored locally. 
# To store it in the S3 bucket, add a backend config in a terraform block:
# OBS: Run the next block only after creating the s3 first 
terraform {
  backend "s3"{
    bucket = "r-terraform-up-and-running-state"
    key = "global/s3/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "r-terraform-up-and-running-locks"
    encrypt = true
  }
}