locals {

  # VPC Name
  vpc_name = local.common_name_prefix
  vpc_cidr = data.aws_vpc.this.cidr_block

}
