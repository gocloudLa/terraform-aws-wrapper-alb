module "security_group_alb" {
  for_each = var.alb_parameters

  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.1"

  create                   = lookup(each.value, "security_group_create", true)
  name                     = lookup(each.value, "security_group_name", "${local.common_name}-lb-${each.key}")
  description              = lookup(each.value, "security_group_description", "Security Group managed by Terraform")
  vpc_id                   = data.aws_vpc.this[each.key].id
  use_name_prefix          = false
  ingress_with_cidr_blocks = lookup(each.value, "ingress_with_cidr_blocks", [])
  egress_with_cidr_blocks = lookup(each.value, "egress_with_cidr_blocks", [
    {
      rule        = "all-all"
      cidr_blocks = data.aws_vpc.this[each.key].cidr_block
    }
  ])
  egress_with_ipv6_cidr_blocks = lookup(each.value, "egress_with_ipv6_cidr_blocks", [])

  tags = merge(local.common_tags, try(each.value.tags, var.alb_defaults.tags, null))
}
