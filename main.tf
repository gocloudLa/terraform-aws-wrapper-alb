module "alb" {
  for_each = var.alb_parameters
  source   = "terraform-aws-modules/alb/aws"
  version  = "10.0.2"

  create                           = true
  create_security_group            = false
  name                             = try(each.value.name, "${local.common_name}-${each.key}")
  region                           = try(each.value.region, var.alb_defaults.region, null)
  security_groups                  = try(each.value.security_group_create, true) ? concat([module.security_group_alb[each.key].security_group_id], try(each.value.security_groups_ids, [])) : []
  drop_invalid_header_fields       = try(each.value.drop_invalid_header_fields, var.alb_defaults.drop_invalid_header_fields, false)
  enable_deletion_protection       = try(each.value.enable_deletion_protection, var.alb_defaults.enable_deletion_protection, false)
  enable_http2                     = try(each.value.enable_http2, var.alb_defaults.enable_http2, true)
  enable_cross_zone_load_balancing = try(each.value.enable_cross_zone_load_balancing, var.alb_defaults.enable_cross_zone_load_balancing, false)
  listeners                        = try(each.value.listeners, var.alb_defaults.listeners, null)
  idle_timeout                     = try(each.value.idle_timeout, var.alb_defaults.idle_timeout, 60)
  ip_address_type                  = try(each.value.ip_address_type, var.alb_defaults.ip_address_type, "ipv4")
  internal                         = try(each.value.internal, var.alb_defaults.internal, false)
  timeouts                         = try(each.value.timeouts, var.alb_defaults.time, null)
  name_prefix                      = try(each.value.name_prefix, var.alb_defaults.name_prefix, null)
  load_balancer_type               = try(each.value.load_balancer_type, var.alb_defaults.load_balancer_type, "application")
  access_logs                      = try(local.access_logs[each.key], var.alb_defaults.access_logs, null)
  subnets                          = try(each.value.subnets, var.alb_defaults.subnets, null)
  subnet_mapping                   = try(each.value.subnet_mapping, var.alb_defaults.subnet_mapping, null)
  target_groups                    = try(each.value.target_groups, var.alb_defaults.target_groups, null)
  vpc_id                           = try(each.value.vpc_id, var.alb_defaults.vpc_id, null)
  enable_waf_fail_open             = try(each.value.enable_waf_fail_open, var.alb_defaults.enable_waf_fail_open, false)
  desync_mitigation_mode           = try(each.value.desync_mitigation_mode, var.alb_defaults.desync_mitigation_mode, "defensive")
  putin_khuylo                     = try(each.value.putin_khuylo, var.alb_defaults.putin_khuylo, true)
  enable_zonal_shift               = try(each.value.enable_zonal_shift, var.alb_defaults.enable_zonal_shift, null)
  ipam_pools                       = try(each.value.ipam_pools, var.alb_defaults.ipam_pools, null)

  # FEATURE VARIABLES
  additional_target_group_attachments                          = try(each.value.additional_target_group_attachments, var.alb_defaults.additional_target_group_attachments, null)
  associate_web_acl                                            = try(each.value.associate_web_acl, var.alb_defaults.associate_web_acl, false)
  client_keep_alive                                            = try(each.value.client_keep_alive, var.alb_defaults.client_keep_alive, null)
  connection_logs                                              = try(each.value.connection_logs, var.alb_defaults.connection_logs, null)
  customer_owned_ipv4_pool                                     = try(each.value.customer_owned_ipv4_pool, var.alb_defaults.customer_owned_ipv4_pool, null)
  default_port                                                 = try(each.value.default_port, var.alb_defaults.default_port, 80)
  default_protocol                                             = try(each.value.default_protocol, var.alb_defaults.default_protocol, "HTTP")
  enable_tls_version_and_cipher_suite_headers                  = try(each.value.enable_tls_version_and_cipher_suite_headers, var.alb_defaults.enable_tls_version_and_cipher_suite_headers, null)
  enable_xff_client_port                                       = try(each.value.enable_xff_client_port, var.alb_defaults.enable_xff_client_port, null)
  enforce_security_group_inbound_rules_on_private_link_traffic = try(each.value.enforce_security_group_inbound_rules_on_private_link_traffic, var.alb_defaults.enforce_security_group_inbound_rules_on_private_link_traffic, null)
  minimum_load_balancer_capacity                               = try(each.value.minimum_load_balancer_capacity, var.alb_defaults.minimum_load_balancer_capacity, null)
  route53_records                                              = try(each.value.route53_records, var.alb_defaults.route53_records, {})
  web_acl_arn                                                  = try(each.value.web_acl_arn, var.alb_defaults.web_acl_arn, null)
  xff_header_processing_mode                                   = try(each.value.xff_header_processing_mode, var.alb_defaults.xff_header_processing_mode, null)
  # dns_record_client_routing_policy                             = try(each.value.dns_record_client_routing_policy, var.alb_defaults.dns_record_client_routing_policy, null)
  # create_security_group                                        = try(each.value.create_security_group, var.alb_defaults.create_security_group, true)
  # security_group_description                                   = try(each.value.security_group_description, var.alb_defaults.security_group_description, null)
  # security_group_egress_rules                                  = try(each.value.security_group_egress_rules, var.alb_defaults.security_group_egress_rules, {})
  # security_group_ingress_rules                                 = try(each.value.security_group_ingress_rules, var.alb_defaults.security_group_ingress_rules, {})
  # security_group_name                                          = try(each.value.security_group_name, var.alb_defaults.security_group_name, null)
  # security_group_tags                                          = try(each.value.security_group_tags, var.alb_defaults.security_group_tags, {})
  # security_group_use_name_prefix                               = try(each.value.security_group_use_name_prefix, var.alb_defaults.security_group_use_name_prefix, true)
  # security_groups                                              = try(each.value.security_groups, var.alb_defaults.security_groups, [])

  tags = merge(local.common_tags, try(each.value.tags, var.alb_defaults.tags, null))
}