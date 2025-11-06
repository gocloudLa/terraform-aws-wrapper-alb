module "wrapper_alb" {
  source = "../../"

  metadata = local.metadata

  alb_parameters = {

    "ExExternal01" = {
      # enable_zonal_shift = true
      # ipam_pools = {}
      subnets  = data.aws_subnets.public.ids
      internal = false
      # vpc_name    = "" # Default: ${local.common_name} (dmc-prd)

      # # Required to create access logs
      # enable_alb_logs        = true # Default: false
      # alb_logs_force_destroy = true # Default: false
      # alb_logs_lifecycle = [] 
      # # Default: [{
      # #   id      = "move-to-onezone-ia"
      # #   enabled = true
      # #   transition = [{
      # #     days          = 30
      # #     storage_class = "ONEZONE_IA"
      # #   }]
      # # }]

      listeners = {
        80 = {
          port     = 80
          protocol = "HTTP"
          redirect = {
            port        = "443"
            protocol    = "HTTPS"
            status_code = "HTTP_301"
          }
        }
        443 = {
          port            = 443
          protocol        = "HTTPS"
          certificate_arn = data.aws_acm_certificate.this.arn
          action_type     = "fixed-response"
          fixed_response = {
            content_type = "text/plain"
            message_body = "Fixed message"
            status_code  = "200"
          }
        }
      }

      ingress_with_cidr_blocks = [
        {
          rule        = "http-80-tcp"
          cidr_blocks = "0.0.0.0/0"
          description = "Enable all access"
        },
        {
          rule        = "https-443-tcp"
          cidr_blocks = "0.0.0.0/0"
          description = "Enable all access"
        }
      ]
      dns_records = {
        "" = {
          zone_name    = "${local.zone_public}"
          private_zone = false
        }
        # To generate a record in the ROOT of the DNS Zone
        # Use as key _null_
        # "_null_" = {
        #   zone_name    = local.zone_public
        #   private_zone = false
        # } # This generates for example https://example.com
      }
    }

    "NlbExample01" = {
      subnets            = data.aws_subnets.public.ids
      internal           = false
      load_balancer_type = "network"
      vpc_id             = data.aws_vpc.this.id

      target_groups = {
        tg80 = {
          name              = "${local.common_name}-nlb-tcp-80"
          protocol          = "TCP"
          port              = 80
          target_type       = "ip"
          vpc_id            = data.aws_vpc.this.id
          create_attachment = false
          health_check = {
            enabled             = true
            protocol            = "TCP"
            port                = 80
            healthy_threshold   = 2
            unhealthy_threshold = 2
            interval            = 10
            timeout             = 6
          }
        }

      }

      listeners = {
        80 = {
          port     = 80
          protocol = "TCP"
          forward = {
            target_group_key = "tg80"
          }
        }
      }

      dns_records = {}

      ingress_with_cidr_blocks = [
        {
          rule        = "http-80-tcp"
          cidr_blocks = "0.0.0.0/0"
          description = "Enable all access"
        },
        {
          rule        = "https-443-tcp"
          cidr_blocks = "0.0.0.0/0"
          description = "Enable all access"
        }
      ]
    }
  }
  alb_defaults = var.alb_defaults
}