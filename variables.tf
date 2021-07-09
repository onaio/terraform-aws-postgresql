variable "postgresql_name" {
  type        = string
  description = "Name to be given to the PostgreSQL RDS instance"
}
variable "postgresql_db_name" {
  type        = string
  description = "Name of the database to create in the RDS instance once it is up"
}
variable "postgresql_owner" {
  type        = string
  description = "Alphabetically ordered comma separated list of Harvest codes of the clients that own this resource"
}
variable "postgresql_env" {
  type        = string
  description = "Alphabetically ordered comma separated list of environments this resource is part of"
}
variable "postgresql_end_date" {
  type        = string
  description = "ISO-8601 date of expiry for resource"
}
variable "postgresql_project" {
  type        = string
  description = "Alphabetically ordered comma separated list of Harvest codes for project IDs resource is part of"
}
variable "postgresql_deployment_type" {
  type        = string
  default     = "vm"
  description = "The deployment type the resource is part of."
}
variable "postgresql_version" {
  type        = string
  description = "The PostgreSQL version for the RDS instance"
}
variable "postgresql_instance_class" {
  type        = string
  description = "The instance type of the RDS instance"
}
variable "postgresql_allocated_storage" {
  type        = number
  default     = 0
  description = "The amount of storage to allocate to the RDS instance in GBs"
}
variable "postgresql_storage_type" {
  type        = string
  default     = "gp2"
  description = "Storage type for the RDS instance. Can be 'gp2', 'standard', 'io1'"
}
variable "postgresql_username" {
  type        = string
  description = "The PostgreSQL superuser to create once instance is up"
}
variable "postgresql_password" {
  type        = string
  description = "The password for the created PostgreSQL superuser"
}
variable "postgresql_vpc_id" {
  type        = string
  description = "The VPC to place the PostgreSQL RDS instance"
}
variable "postgresql_firewall_rule_ingress_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks to allow to access the PostgreSQL instance"
}
variable "postgresql_subnet_ids" {
  type        = list(string)
  description = "The subnet IDs to place the PostgreSQL instance's subnet group in"
}
variable "postgresql_deletion_protection" {
  type        = bool
  default     = true
  description = "Whether to protect the RDS instance from deletion. Default is true"
}
variable "postgresql_multi_az" {
  type        = bool
  default     = false
  description = "Whether the RDS instance should have multi-AZ turned on. Default is false"
}
variable "postgresql_port" {
  type        = number
  default     = 5432
  description = "The port PostgreSQL should listen on in the RDS instance"
}
variable "postgresql_copy_tags_to_snapshot" {
  type        = bool
  default     = true
  description = "Whether to copy tags on the RDS instance to its snapshots. Default is true"
}
variable "postgresql_domain_names" {
  type        = list(string)
  description = "The domain name to assign to the RDS instance (without the zone name)"
  default     = []
}
variable "postgresql_domain_zone_name" {
  type        = string
  description = "The domain zone the RDS instance's domain should be part of"
  default     = ""
}
variable "postgresql_backup_retention_period" {
  type        = number
  default     = 35
  description = "Number of days to retain snapshots after they're created"
}
variable "postgresql_backup_window" {
  type        = string
  default     = "03:30-05:00"
  description = "Window in which instance snapshots will be created as backups"
}
variable "postgresql_parameter_group_family" {
  type        = string
  default     = ""
  description = "The family for the PostgreSQL instance's parameter group. Is usually tied to the PostgreSQL version. If set to blank string, module will use the first part of the PostgreSQL version to determine the name of the family"
}
variable "postgresql_alarm_connections_evaluation_periods" {
  type        = string
  default     = "1"
  description = "The number of periods over which data is compared to the specified threshold"
}
variable "postgresql_alarm_connections_period" {
  type        = string
  default     = "60"
  description = "The period in seconds over which the average operation is applied"
}
variable "postgresql_alarm_connections_threshold" {
  type        = number
  default     = 120
  description = "The threshold of database connections above which an alarm will be raised"
}
variable "postgresql_track_activity_query_size" {
  type        = number
  default     = 1024
  description = "The number of bytes reserved to track the currently executing command for each active session"
}
variable "postgresql_pg_stat_statements_max" {
  type        = number
  default     = 5000
  description = "The maximum number of statements tracked by the pg_stat_statements module"
}
variable "postgresql_pg_stat_statements_track" {
  type        = string
  default     = "top"
  description = "Controls which statements are counted by the pg_stat_statements module"
}
variable "postgresql_pg_stat_statements_track_utility" {
  type        = bool
  default     = true
  description = "Controls whether utility commands are tracked by the pg_stat_statements module"
}
variable "postgresql_pg_stat_statements_save" {
  type        = bool
  default     = true
  description = "Specifies whether to save statement statistics tracked by the pg_stat_statements module across server shutdowns"
}
variable "postgresql_alarm_alarm_actions" {
  type        = list(string)
  default     = []
  description = "The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}
variable "postgresql_alarm_insufficient_data_actions" {
  type        = list(string)
  default     = []
  description = "The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}
variable "postgresql_alarm_ok_actions" {
  type        = list(string)
  default     = []
  description = "The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}
variable "postgresql_apply_immediately" {
  type        = bool
  default     = false
  description = "Whether to apply RDS changes immediately or on the next maintenance window."
}
variable "postgresql_publicly_accessible" {
  type        = bool
  default     = false
  description = "Whether RDS should be publicly accessible."
}
variable "postgresql_parameter_group_apply_method" {
  type        = string
  default     = "pending-reboot"
  description = "Can be either 'immediate' or 'pending-reboot'. Specifies when the parameter group parameters should be applied to the database."
}
variable "postgresql_source_snapshot_identifier" {
  type        = string
  default     = ""
  description = "This is the snapshot id. It would normally be found on the AWS console. Specifies whether or not to create this database from a snapshot."
}
variable "postgresql_storage_encrypted" {
  type        = bool
  default     = true
  description = "Specifies whether the DB instance is encrypted. Note that if you are creating a cross-region read replica this field is ignored and you should instead declare kms_key_id with a valid ARN. The default is false if not specified."
}
variable "postgresql_performance_insights_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether Performance Insights are enabled. Defaults to false."
}
variable "postgresql_datapoints_to_alarm" {
  type        = number
  default     = null
  description = "Specifies whether Performance Insights are enabled. Defaults to false."
}
variable "postgresql_replicate_source_db" {
  type        = string
  default     = ""
  description = "The identifier of another Amazon RDS Database to replicate (if replicating within a single region) or Amazon Resource Name (ARN) of the Amazon RDS Database to replicate (if replicating cross-region)."
}

variable "postgresql_parameters" {
  type = map(object({
    name  = string
    value = any
  }))
  default     = {}
  description = "The map of DB parameters and their values"
}

variable "extra_security_groups"{
  type = list(string)
  description = "Extra security groups to add to the RDS instance"
  default = []
}