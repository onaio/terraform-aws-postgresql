resource "aws_db_instance" "blank-database" {
  count = length(var.postgresql_source_snapshot_identifier) == 0 ? 1 : 0

  apply_immediately            = var.postgresql_apply_immediately
  identifier                   = var.postgresql_name
  allocated_storage            = var.postgresql_allocated_storage
  storage_type                 = var.postgresql_storage_type
  engine                       = "postgres"
  engine_version               = var.postgresql_version
  instance_class               = var.postgresql_instance_class
  name                         = var.postgresql_db_name
  username                     = var.postgresql_username
  password                     = var.postgresql_password
  parameter_group_name         = aws_db_parameter_group.main.name
  db_subnet_group_name         = aws_db_subnet_group.main.name
  deletion_protection          = var.postgresql_deletion_protection
  multi_az                     = var.postgresql_multi_az
  port                         = var.postgresql_port
  copy_tags_to_snapshot        = var.postgresql_copy_tags_to_snapshot
  storage_encrypted            = var.postgresql_storage_encrypted
  kms_key_id                   = aws_kms_key.main.arn
  vpc_security_group_ids       = [aws_security_group.firewall_rule.id]
  final_snapshot_identifier    = var.postgresql_name
  backup_retention_period      = var.postgresql_backup_retention_period
  backup_window                = var.postgresql_backup_window
  replicate_source_db          = var.postgresql_replicate_source_db
  publicly_accessible          = var.postgresql_publicly_accessible
  performance_insights_enabled = var.postgresql_performance_insights_enabled
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

  apply_immediately      = var.postgresql_apply_immediately
  identifier             = var.postgresql_name
  storage_type           = var.postgresql_storage_type
  instance_class         = var.postgresql_instance_class
  parameter_group_name   = aws_db_parameter_group.main.name
  db_subnet_group_name   = aws_db_subnet_group.main.name
  deletion_protection    = var.postgresql_deletion_protection
  multi_az               = var.postgresql_multi_az
  port                   = var.postgresql_port
  storage_encrypted      = var.postgresql_storage_encrypted
  kms_key_id             = aws_kms_key.main.arn
  vpc_security_group_ids = [aws_security_group.firewall_rule.id]
  snapshot_identifier    = var.postgresql_source_snapshot_identifier
  skip_final_snapshot    = true
  publicly_accessible    = var.postgresql_publicly_accessible
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
    value        = var.postgresql_pg_stat_statements_track_utility
    apply_method = var.postgresql_parameter_group_apply_method
  }

  parameter {
    name         = "pg_stat_statements.save"
    value        = var.postgresql_pg_stat_statements_save
    apply_method = var.postgresql_parameter_group_apply_method
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
    DBInstanceIdentifier = length(var.postgresql_source_snapshot_identifier) == 0 ? aws_db_instance.blank-database[0].id : aws_db_instance.from-snapshot[0].id
  }
}
