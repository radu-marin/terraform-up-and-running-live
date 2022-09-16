# With the previous backend enabled, Terraform will automatically
# pull the latest state from the S3 bucket before running a command,
# and automatically push the latest state to the S3 after running a command.
# To see this in action, add the following output variables:
output "s3_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table"
}