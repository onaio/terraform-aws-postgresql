resource "aws_db_instance" "blank-database" {
  count = length(var.postgresql_source_snapshot_identifier) == 0 && length(var.postgresql_replicate_source_db) == 0 ? 1 : 0

  apply_immediately               = var.postgresql_apply_immediately
  identifier                      = var.postgresql_name
  allocated_storage               = var.postgresql_allocated_storage
  storage_type                    = var.postgresql_storage_type
  engine                          = "postgres"
  engine_version                  = var.postgresql_version
  instance_class                  = var.postgresql_instance_class
  db_name                         = var.postgresql_db_name
  username                        = var.postgresql_username
  password                        = var.postgresql_password
  parameter_group_name            = aws_db_parameter_group.main.name
  db_subnet_group_name            = aws_db_subnet_group.main.name
  deletion_protection             = var.postgresql_deletion_protection
  multi_az                        = var.postgresql_multi_az
  port                            = var.postgresql_port
  copy_tags_to_snapshot           = var.postgresql_copy_tags_to_snapshot
  storage_encrypted               = var.postgresql_storage_encrypted
  kms_key_id                      = aws_kms_key.main.arn
  vpc_security_group_ids          = [aws_security_group.firewall_rule.id]
  final_snapshot_identifier       = var.postgresql_name
  backup_retention_period         = var.postgresql_backup_retention_period
  backup_window                   = var.postgresql_backup_window
  replicate_source_db             = length(var.postgresql_source_snapshot_identifier) == 0 && length(var.postgresql_replicate_source_db) != 0 ? var.postgresql_replicate_source_db : null
  publicly_accessible             = var.postgresql_publicly_accessible
  performance_insights_enabled    = var.postgresql_performance_insights_enabled
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Name            = var.postgresql_name
    OwnerList       = var.postgresql_owner
    EnvironmentList = var.postgresql_env
    ProjectList     = var.postgresql_project
    DeploymentType  = var.postgresql_deployment_type
    EndDate         = var.postgresql_end_date
  }
}

resource "aws_db_instance" "from-snapshot" {
  count = length(var.postgresql_source_snapshot_identifier) == 0 ? 0 : 1

  apply_immediately               = var.postgresql_apply_immediately
  identifier                      = var.postgresql_name
  storage_type                    = var.postgresql_storage_type
  instance_class                  = var.postgresql_instance_class
  parameter_group_name            = aws_db_parameter_group.main.name
  db_subnet_group_name            = aws_db_subnet_group.main.name
  deletion_protection             = var.postgresql_deletion_protection
  multi_az                        = var.postgresql_multi_az
  port                            = var.postgresql_port
  storage_encrypted               = var.postgresql_storage_encrypted
  kms_key_id                      = aws_kms_key.main.arn
  vpc_security_group_ids          = [aws_security_group.firewall_rule.id]
  snapshot_identifier             = var.postgresql_source_snapshot_identifier
  skip_final_snapshot             = true
  publicly_accessible             = var.postgresql_publicly_accessible
  performance_insights_enabled    = var.postgresql_performance_insights_enabled
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Name            = var.postgresql_name
    OwnerList       = var.postgresql_owner
    EnvironmentList = var.postgresql_env
    ProjectList     = var.postgresql_project
    DeploymentType  = var.postgresql_deployment_type
    EndDate         = var.postgresql_end_date
  }

  lifecycle {
    ignore_changes = [
      # When creating an RDS instance from a snapshot, it still uses the snapshot's kms_key_id.
      # There is no way to change it and it will always prompt for recreating the instance
      # without changing it after a successful apply. See discussion on
      # https://github.com/terraform-providers/terraform-provider-aws/issues/6063.
      kms_key_id,
    ]
  }
}

resource "aws_db_instance" "replica-database" {
  count = length(var.postgresql_replicate_source_db) == 0 ? 0 : 1

  apply_immediately               = var.postgresql_apply_immediately
  identifier                      = var.postgresql_name
  allocated_storage               = var.postgresql_allocated_storage
  storage_type                    = var.postgresql_storage_type
  engine                          = "postgres"
  engine_version                  = var.postgresql_version
  instance_class                  = var.postgresql_instance_class
  db_name                         = var.postgresql_db_name
  username                        = var.postgresql_username
  parameter_group_name            = aws_db_parameter_group.main.name
  db_subnet_group_name            = aws_db_subnet_group.main.name
  deletion_protection             = var.postgresql_deletion_protection
  multi_az                        = var.postgresql_multi_az
  port                            = var.postgresql_port
  copy_tags_to_snapshot           = var.postgresql_copy_tags_to_snapshot
  storage_encrypted               = var.postgresql_storage_encrypted
  kms_key_id                      = aws_kms_key.main.arn
  vpc_security_group_ids          = [aws_security_group.firewall_rule.id]
  replicate_source_db             = var.is_promoted_to_standalone ? "" : var.postgresql_replicate_source_db
  publicly_accessible             = var.postgresql_publicly_accessible
  performance_insights_enabled    = var.postgresql_performance_insights_enabled
  backup_retention_period         = var.standalone_db_enable_backup ? var.postgresql_backup_retention_period : 0
  backup_window                   = var.standalone_db_enable_backup ? var.postgresql_backup_window : null
  enabled_cloudwatch_logs_exports = ["postgresql"]
  skip_final_snapshot             = true

  tags = {
    Name            = var.postgresql_name
    OwnerList       = var.postgresql_owner
    EnvironmentList = var.postgresql_env
    ProjectList     = var.postgresql_project
    DeploymentType  = var.postgresql_deployment_type
    EndDate         = var.postgresql_end_date
  }
}

resource "aws_db_parameter_group" "main" {
  name   = var.postgresql_name
  family = length(var.postgresql_parameter_group_family) > 0 ? var.postgresql_parameter_group_family : "postgres${element(split(".", var.postgresql_version), 0)}"

  parameter {
    name         = "track_activity_query_size"
    value        = var.postgresql_track_activity_query_size
    apply_method = var.postgresql_parameter_group_apply_method
  }

  parameter {
    name         = "pg_stat_statements.max"
    value        = var.postgresql_pg_stat_statements_max
    apply_method = var.postgresql_parameter_group_apply_method
  }

  parameter {
    name         = "pg_stat_statements.track"
    value        = var.postgresql_pg_stat_statements_track
    apply_method = var.postgresql_parameter_group_apply_method
  }

  parameter {
    name         = "pg_stat_statements.track_utility"
    value        = var.postgresql_pg_stat_statements_track_utility ? 1 : 0
    apply_method = var.postgresql_parameter_group_apply_method
  }

  parameter {
    name         = "pg_stat_statements.save"
    value        = var.postgresql_pg_stat_statements_save ? 1 : 0
    apply_method = var.postgresql_parameter_group_apply_method
  }

  parameter {
    name         = "log_min_duration_statement"
    value        = var.log_min_duration_statement
    apply_method = var.postgresql_parameter_group_apply_method
  }

  dynamic "parameter" {
    for_each = var.postgresql_parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = var.postgresql_parameter_group_apply_method
    }
  }

  tags = {
    Name            = var.postgresql_name
    OwnerList       = var.postgresql_owner
    EnvironmentList = var.postgresql_env
    ProjectList     = var.postgresql_project
    DeploymentType  = var.postgresql_deployment_type
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
    DeploymentType  = var.postgresql_deployment_type
    EndDate         = var.postgresql_end_date
  }
}

resource "aws_cloudwatch_metric_alarm" "db-connections" {
  alarm_name                = "rds-${var.postgresql_name}-connections"
  comparison_operator       = "GreaterThanThreshold"
  datapoints_to_alarm       = var.postgresql_datapoints_to_alarm
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
    DBInstanceIdentifier = (length(var.postgresql_source_snapshot_identifier) == 0 && length(var.postgresql_replicate_source_db) == 0) ? aws_db_instance.blank-database[0].id : length(var.postgresql_replicate_source_db) != 0 ? aws_db_instance.replica-database[0].id : aws_db_instance.from-snapshot[0].id
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_too_high" {
  alarm_name          = "rds-${var.postgresql_name}-cpu-utilizations"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.postgresql_cpu_utilization_period
  statistic           = "Average"
  threshold           = var.postgresql_cpu_utilization_threshold
  alarm_description   = "Average database CPU utilization too high"
  alarm_actions       = var.postgresql_alarm_actions
  ok_actions          = var.postgresql_ok_actions

  dimensions = {
    DBInstanceIdentifier = (length(var.postgresql_source_snapshot_identifier) == 0 && length(var.postgresql_replicate_source_db) == 0) ? aws_db_instance.blank-database[0].id : length(var.postgresql_replicate_source_db) != 0 ? aws_db_instance.replica-database[0].id : aws_db_instance.from-snapshot[0].id
  }
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space_too_low" {
  alarm_name          = "free-storage-space-threshold-${var.postgresql_name}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = var.postgresql_storage_space_period
  statistic           = "Average"
  threshold           = var.postgresql_free_storage_space_threshold
  alarm_description   = "Average database free storage too low"
  alarm_actions       = var.postgresql_alarm_actions
  ok_actions          = var.postgresql_ok_actions

  dimensions = {
    DBInstanceIdentifier = (length(var.postgresql_source_snapshot_identifier) == 0 && length(var.postgresql_replicate_source_db) == 0) ? aws_db_instance.blank-database[0].id : length(var.postgresql_replicate_source_db) != 0 ? aws_db_instance.replica-database[0].id : aws_db_instance.from-snapshot[0].id
  }
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory_too_low" {
  alarm_name          = "freeable-memory-too-low-${var.postgresql_name}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = var.postgresql_freeable_memory_period
  statistic           = "Average"
  threshold           = var.postgresql_freeable_memory_threshold
  alarm_description   = "Average database freeable memory over last set period"
  alarm_actions       = var.postgresql_alarm_actions
  ok_actions          = var.postgresql_ok_actions

  dimensions = {
    DBInstanceIdentifier = (length(var.postgresql_source_snapshot_identifier) == 0 && length(var.postgresql_replicate_source_db) == 0) ? aws_db_instance.blank-database[0].id : length(var.postgresql_replicate_source_db) != 0 ? aws_db_instance.replica-database[0].id : aws_db_instance.from-snapshot[0].id
  }
}

resource "aws_cloudwatch_log_metric_filter" "slow_query_metric_filter" {
  count = length(var.postgresql_alarm_actions) == 0 ? 0 : 1

  log_group_name = "/aws/rds/instance/${var.postgresql_name}/postgresql"
  name           = var.postgresql_slow_query_metric_filter_name
  pattern        = join("?", var.postgresql_slow_query_pattern)
  metric_transformation {
    name      = var.postgresql_slow_query_metric_filter_name
    namespace = var.postgresql_slow_query_metric_namespace
    value     = var.postgresql_slow_query_metric_value
  }
}

resource "aws_cloudwatch_metric_alarm" "slow_query_metric_alarm" {
  count = length(var.postgresql_alarm_actions) == 0 ? 0 : 1

  alarm_name          = var.postgresql_slow_query_alarm_name
  alarm_description   = var.postgresql_slow_query_alarm_description
  comparison_operator = var.postgresql_slow_query_comparison_operator
  evaluation_periods  = var.postgresql_slow_query_evaluation_periods
  metric_name         = var.postgresql_slow_query_metric_filter_name
  namespace           = var.postgresql_slow_query_metric_namespace
  period              = var.postgresql_slow_query_period
  threshold           = var.postgresql_slow_query_threshold
  statistic           = var.postgresql_slow_query_statistic
  alarm_actions       = var.postgresql_alarm_actions
  tags                = { notification_type = var.postgresql_slow_query_notification_type, severity = var.postgresql_slow_query_severity }
}
