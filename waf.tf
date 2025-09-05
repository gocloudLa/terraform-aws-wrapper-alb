/*----------------------------------------------------------------------*/
/* ALB WAF General Variables                                            */
/*----------------------------------------------------------------------*/
locals {
  alb_waf = {
    for key, value in var.alb_parameters :
    key => value
    if try(value.waf_rules, null) != null
  }
}

module "alb_waf" {
  for_each = local.alb_waf
  source   = "umotif-public/waf-webaclv2/aws"
  version  = "~> 5.1.2"

  enabled                = true
  name_prefix            = "${local.common_name}-${each.key}"
  scope                  = "REGIONAL"
  create_alb_association = true
  alb_arn                = module.alb[each.key].arn

  allow_default_action = try(each.value.waf_allow_default_action, true)
  visibility_config    = try(each.value.waf_visibility_config, { metric_name = "${local.common_name}-${each.key}" })
  rules                = try(each.value.waf_rules, [{ name = "disabled" }])

  # Logging
  create_logging_configuration = try(each.value.waf_logging_enable, false)
  log_destination_configs      = try([aws_cloudwatch_log_group.alb_waf[each.key].arn], [])
  logging_filter               = try(each.value.waf_logging_filter, local.waf_logging_filter_default)

  tags = local.common_tags
}

locals {
  waf_logging_filter_default = {
    default_behavior = "DROP"

    filter = [
      {
        behavior    = "KEEP"
        requirement = "MEETS_ANY"
        condition = [
          {
            action_condition = {
              action = "COUNT"
            }
          },
          {
            action_condition = {
              action = "BLOCK"
            }
          }
        ]
      }
    ]
  }
}

/*----------------------------------------------------------------------*/
/* ALB WAF Logging Variables                                            */
/*----------------------------------------------------------------------*/
locals {
  alb_waf_logging = {
    for key, value in local.alb_waf :
    key => value
    if try(value.waf_logging_enable, false) != false
  }
}

resource "aws_cloudwatch_log_group" "alb_waf" {
  for_each = local.alb_waf_logging
  name     = "aws-waf-logs-${local.common_name}-${each.key}"

  retention_in_days = try(each.value.waf_logging_retention, 7)

  tags = local.common_tags
}

resource "aws_cloudwatch_log_resource_policy" "alb_waf" {
  for_each        = local.alb_waf_logging
  policy_document = data.aws_iam_policy_document.alb_waf[each.key].json
  policy_name     = "${local.common_name}-${each.key}"
}

data "aws_iam_policy_document" "alb_waf" {
  for_each = local.alb_waf_logging
  version  = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = ["delivery.logs.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.alb_waf[each.key].arn}:*"]
    condition {
      test     = "ArnLike"
      values   = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"]
      variable = "aws:SourceArn"
    }
    condition {
      test     = "StringEquals"
      values   = [tostring(data.aws_caller_identity.current.account_id)]
      variable = "aws:SourceAccount"
    }
  }
}

# /*----------------------------------------------------------------------*/
# /* ALB WAF Alerts Variables                                             */
# /*----------------------------------------------------------------------*/
# resource "aws_cloudwatch_metric_alarm" "alb_waf_alarm_blocked" {
#   for_each = local.alb_waf

#   alarm_name                = "${local.common_name}-${each.key}-blocked"
#   comparison_operator       = "GreaterThanUpperThreshold"
#   evaluation_periods        = "1"
#   threshold_metric_id       = "ad1"
#   alarm_description         = "This metric monitors WAF BlockedRequests"
#   insufficient_data_actions = []
#   actions_enabled           = "true"
#   treat_missing_data        = "notBreaching"
#   # alarm_actions             = [data.aws_sns_topic.project-alerts.arn]
#   # ok_actions                = [data.aws_sns_topic.project-alerts.arn]
#   alarm_actions = [var.aws_sns_topic_alerts]
#   ok_actions    = [var.aws_sns_topic_alerts]

#   metric_query {
#     id          = "ad1"
#     expression  = "ANOMALY_DETECTION_BAND(m1, 4)"
#     label       = "BlockedRequests (Expected)"
#     return_data = "true"
#   }

#   metric_query {
#     id          = "m1"
#     return_data = "true"
#     metric {
#       metric_name = "BlockedRequests"
#       namespace   = "AWS/WAFV2"
#       period      = "900"
#       stat        = "Average"

#       dimensions = {
#         WebACL = module.alb_waf[each.key].web_acl_name
#         Rule   = "ALL"
#         Region = local.metadata.aws_region
#       }
#     }
#   }
# }