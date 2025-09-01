data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "this" {
  for_each = var.alb_parameters
  filter {
    name = "tag:Name"
    values = [
      try(each.value.vpc_name, local.default_vpc_name)
    ]
  }
}