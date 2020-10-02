output "postgres_aws_db_instance_arns" {
  value       = aws_db_instance.blank-database.*.arn
  description = "Outputs the Amazon Resource Name (ARN) of instance incase we need to create a read replica of this instance"
}

