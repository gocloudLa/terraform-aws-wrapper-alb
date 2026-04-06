locals {
  # Unified logging config per ALB
  logging_config = {
    for alb_key, alb_config in var.alb_parameters :
    alb_key => {
      enable_access_logs       = try(alb_config.enable_access_logs, false)
      enable_connection_logs   = try(alb_config.enable_connection_logs, false)
      enable_health_check_logs = try(alb_config.enable_health_check_logs, false)

      # Optional existing bucket (to reuse instead of creating one)
      bucket_logs = try(alb_config.bucket_logs, null)

      # Create a bucket only if:
      # - at least one of the 3 flags is true
      # - and NO explicit bucket was provided (bucket_logs == null)
      create_bucket = (
        (
          try(alb_config.enable_access_logs, false)
          || try(alb_config.enable_connection_logs, false)
          || try(alb_config.enable_health_check_logs, false)
        )
        && try(alb_config.bucket_logs, null) == null
      )

      force_destroy = try(alb_config.alb_logs_force_destroy, false)
      lifecycle_rule = try(alb_config.alb_logs_lifecycle, [
        {
          id      = "move-to-onezone-ia"
          enabled = true
          transition = [{
            days          = 30
            storage_class = "ONEZONE_IA"
          }]
        }
      ])
    }
  }
}

module "elb_bucket" {
  # One bucket per ALB; the creation is decided by create_bucket
  for_each = local.logging_config

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.12.0"

  bucket = lower(substr("${local.common_name}-${each.key}-logs", 0, 63))

  create_bucket                  = each.value.create_bucket
  force_destroy                  = each.value.force_destroy
  object_lock_enabled            = true
  control_object_ownership       = true
  attach_elb_log_delivery_policy = true
  lifecycle_rule                 = each.value.lifecycle_rule

  access_log_delivery_policy_source_accounts = [data.aws_caller_identity.current.account_id]

  tags = local.common_tags
}

locals {
  # Access logs for the ALB
  access_logs = {
    for alb_key, alb_config in local.logging_config :
    alb_key => {
      bucket  = coalesce(alb_config.bucket_logs, module.elb_bucket[alb_key].s3_bucket_id)
      enabled = alb_config.enable_access_logs
      prefix  = "access-logs"
    }
    if alb_config.enable_access_logs
  }

  # Connection logs for the ALB
  connection_logs_local = {
    for alb_key, alb_config in local.logging_config :
    alb_key => {
      enabled = alb_config.enable_connection_logs
      bucket  = coalesce(alb_config.bucket_logs, module.elb_bucket[alb_key].s3_bucket_id)
      prefix  = "connection-logs"
    }
    if alb_config.enable_connection_logs
  }

  # Health check logs for the ALB
  health_check_logs_local = {
    for alb_key, alb_config in local.logging_config :
    alb_key => {
      enabled = alb_config.enable_health_check_logs
      bucket  = coalesce(alb_config.bucket_logs, module.elb_bucket[alb_key].s3_bucket_id)
      prefix  = "health-check-logs"
    }
    if alb_config.enable_health_check_logs
  }
}