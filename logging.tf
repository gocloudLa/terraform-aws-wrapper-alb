locals {
  access_logs_calculated = {
    for alb_key, alb_config in var.alb_parameters :
    alb_key => {
      "create_bucket" = try(alb_config.enable_alb_logs, false)
      "force_destroy" = try(alb_config.alb_logs_force_destroy, false)
      "lifecycle_rule" = try(alb_config.alb_logs_lifecycle, [
        {
          id      = "move-to-onezone-ia"
          enabled = true
          transition = [{
            days          = 30
            storage_class = "ONEZONE_IA"
          }]
        }
      ])
    } if try(alb_config.enable_alb_logs, false) == true
  }
}

module "elb_bucket" {
  for_each = local.access_logs_calculated

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.8.2"

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
  access_logs = {
    for alb_key, alb_config in var.alb_parameters :
    alb_key => {
      "bucket"  = module.elb_bucket[alb_key].s3_bucket_id
      "enabled" = try(alb_config.enable_alb_logs, false)
    } if try(alb_config.enable_alb_logs, false) == true
  }
}