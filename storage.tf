resource "aws_db_instance" "main" {
  apply_immediately         = var.postgresql_apply_immediately
  identifier                = var.postgresql_name
  allocated_storage         = var.postgresql_allocated_storage
  storage_type              = var.postgresql_storage_type
  engine                    = "postgres"
  engine_version            = var.postgresql_version
  instance_class            = var.postgresql_instance_class
  name                      = var.postgresql_db_name
  username                  = var.postgresql_username
  password                  = var.postgresql_password
  parameter_group_name      = aws_db_parameter_group.main.name
  db_subnet_group_name      = aws_db_subnet_group.main.name
  deletion_protection       = var.postgresql_deletion_protection
  multi_az                  = var.postgresql_multi_az
  port                      = var.postgresql_port
  copy_tags_to_snapshot     = var.postgresql_copy_tags_to_snapshot
  storage_encrypted         = true
  kms_key_id                = aws_kms_key.main.arn
  vpc_security_group_ids    = [aws_security_group.firewall_rule.id]
  final_snapshot_identifier = var.postgresql_name
  backup_retention_period   = var.postgresql_backup_retention_period
  backup_window             = var.postgresql_backup_window
  tags = {
    Name            = var.postgresql_name
    OwnerList       = var.postgresql_owner
    EnvironmentList = var.postgresql_env
    ProjectList     = var.postgresql_project
    EndDate         = var.postgresql_end_date
  }
}

resource "aws_db_parameter_group" "main" {
  name                              = var.postgresql_name
  track_activity_query_size         = var.postgresql_track_activity_query_size
  pg_stat_statements.max            = var.postgresql_pg_stat_statements_max
  pg_stat_statements.track          = var.postgresql_pg_stat_statements_track
  pg_stat_statements.track_utility  = var.postgresql_pg_stat_statements_track_utility
  pg_stat_statements.save           = var.postgresql_pg_stat_statements_save
  family = length(var.postgresql_parameter_group_family) > 0 ? var.postgresql_parameter_group_family : "postgres${element(split(".", var.postgresql_version), 0)}"
  tags = {
    Name            = var.postgresql_name
    OwnerList       = var.postgresql_owner
    EnvironmentList = var.postgresql_env
    ProjectList     = var.postgresql_project
    EndDate         = var.postgresql_end_date
  }
}

resource "aws_kms_key" "main" {
  description = "PostgreSQL at rest encryption key for ${var.postgresql_name}"
  tags = {
    Name            = var.postgresql_name
    OwnerList       = var.postgresql_owner
    EnvironmentList = var.postgresql_env
    ProjectList     = var.postgresql_project
    EndDate         = var.postgresql_end_date
  }
}

resource "aws_cloudwatch_metric_alarm" "db-connections" {
  alarm_name                = "rds-${var.postgresql_name}-connections"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = var.postgresql_alarm_connections_evaluation_periods
  metric_name               = "DatabaseConnections"
  namespace                 = "AWS/RDS"
  period                    = var.postgresql_alarm_connections_period
  statistic                 = "Average"
  threshold                 = var.postgresql_alarm_connections_threshold
  alarm_actions             = var.postgresql_alarm_alarm_actions
  ok_actions                = var.postgresql_alarm_ok_actions
  insufficient_data_actions = var.postgresql_alarm_insufficient_data_actions

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }
}
