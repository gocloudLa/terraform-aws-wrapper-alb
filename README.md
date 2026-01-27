# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform ALB Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-alb/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-alb.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-alb.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-alb/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform Wrapper for ALB simplifies the configuration of Load Balancer Services in the AWS cloud. This wrapper functions as a predefined template, facilitating the creation and management of Load Balancers by handling all the technical details.

### ✨ Features

- 🛡️ [Web Application Firewall](#web-application-firewall) - Configures WAF rules and automatically attaches WebACL to ALB listeners

- 🌐 [DNS Record](#dns-record) - Registers a CNAME DNS record in a Route53 hosted zone

- 📜 [Access Log](#access-log) - Create S3 bucket and configure LoadBalancer access log in S3



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-alb" target="_blank">terraform-aws-modules/alb/aws</a> | 10.5.0 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-s3-bucket" target="_blank">terraform-aws-modules/s3-bucket/aws</a> | 5.8.2 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-security-group" target="_blank">terraform-aws-modules/security-group/aws</a> | 5.3.1 |
| <a href="https://github.com/umotif-public/terraform-aws-waf-webaclv2" target="_blank">umotif-public/waf-webaclv2/aws</a> | 5.1.2 |



## 🚀 Quick Start
```hcl
alb_parameters = {
    "ExExternal00" = {
      subnets  = data.aws_subnets.public.ids
      internal = false
      # vpc_name    = "" # Default: ${local.common_name} (dmc-prd)

      # # Required to create access logs
      # enable_alb_logs        = true # Default: false
      # alb_logs_force_destroy = true # Default: false
      # alb_logs_lifecycle = [] # Default: [{
      #   id      = "move-to-onezone-ia"
      #   enabled = true
      #   transition = [{
      #     days          = 30
      #     storage_class = "ONEZONE_IA"
      #   }]
      # }]

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
  }
  alb_defaults = var.alb_defaults
```


## 🔧 Additional Features Usage

### Web Application Firewall
Perform the creation and configuration of WAF rules (WebAcl) as requested in the configuration, the new WebAcl generated is attached by default to the listeners used by the Amazon ALB service.


<details><summary>Configuration Code</summary>

```hcl
alb_parameters = {
  "external-00" = {
    ...
    waf_logging_enable    = true
    waf_logging_filter    = {} # Log All events (default only COUNT & BLOCK)
    # waf_logging_retention =  # Default 7 days
    waf_rules = [
      {
        name     = "AWSManagedRulesCommonRuleSet-rule-1"
        priority = "10"

        override_action = "none"

        visibility_config = {
          metric_name = "AWSManagedRulesCommonRuleSet-metric"
        }

        managed_rule_group_statement = {
          name        = "AWSManagedRulesCommonRuleSet" //WCU 700
          vendor_name = "AWS"
          rule_action_overrides = [
            {
              name = "SizeRestrictions_Cookie_HEADER"
              action_to_use = { count = {} }
            },
            {
              name = "SizeRestrictions_BODY"
              action_to_use = { count = {} }
            },
            {
              name = "EC2MetaDataSSRF_BODY"
              action_to_use = { count = {} }
            },
            {
              name = "EC2MetaDataSSRF_COOKIE"
              action_to_use = { count = {} }
            },
            {
              name = "EC2MetaDataSSRF_URIPATH"
              action_to_use = { count = {} }
            },
            {
              name = "EC2MetaDataSSRF_QUERYARGUMENTS"
              action_to_use = { count = {} }
            },
            {
              name = "CrossSiteScripting_BODY"
              action_to_use = { count = {} }
            },
            {
              name = "NoUserAgent_HEADER"
              action_to_use = { count = {} }
            },
            {
              name = "SizeRestrictions_QUERYSTRING"
              action_to_use = { count = {} }
            },
            {
              name = "GenericLFI_BODY"
              action_to_use = { count = {} }
            },
            {
              name = "GenericRFI_BODY"
              action_to_use = { count = {} }
            }
          ]
        }
      },
      {
        name     = "AWSManagedRulesKnownBadInputsRuleSet-rule-2"
        priority = "20"

        override_action = "none"

        visibility_config = {
          metric_name = "AWSManagedRulesKnownBadInputsRuleSet-metric"
        }

        managed_rule_group_statement = {
          name        = "AWSManagedRulesKnownBadInputsRuleSet" //WCU 200
          vendor_name = "AWS"
          rule_action_overrides = [
            {
              name = "PROPFIND_METHOD"
              action_to_use = { count = {} }
            },
            {
              name = "Log4JRCE"
              action_to_use = { count = {} }
            }
          ]
        }
      },
      {
        name     = "AWSManagedRulesSQLiRuleSet-rule-3"
        priority = "30"

        override_action = "none"

        visibility_config = {
          metric_name = "AWSManagedRulesSQLiRuleSet-metric"
        }

        managed_rule_group_statement = {
          name        = "AWSManagedRulesSQLiRuleSet" //WCU 200
          vendor_name = "AWS"
          rule_action_overrides = [
            {
              name = "SQLi_BODY"
              action_to_use = { count = {} }
            }
          ]
        }
      },
      {
        name     = "AWSManagedRulesLinuxRuleSet-rule-4"
        priority = "40"

        override_action = "none"

        visibility_config = {
          metric_name = "AWSManagedRulesLinuxRuleSet-metric"
        }

        managed_rule_group_statement = {
          name        = "AWSManagedRulesLinuxRuleSet" //WCU 700
          vendor_name = "AWS"

        }
      },
      {
        name     = "AWSManagedRulesAmazonIpReputationList-rule-5"
        priority = "50"

        override_action = "none"

        visibility_config = {
          metric_name = "AWSManagedRulesAmazonIpReputationList-metric"
        }

        managed_rule_group_statement = {
          name        = "AWSManagedRulesAmazonIpReputationList" //WCU 25
          vendor_name = "AWS"
        }
      },
      {
        name     = "AWSManagedRulesAnonymousIpList-rule-6"
        priority = "60"

        override_action = "none"

        visibility_config = {
          metric_name = "AWSManagedRulesAnonymousIpList-metric"
        }

        managed_rule_group_statement = {
          name        = "AWSManagedRulesAnonymousIpList" //WCU 50
          vendor_name = "AWS"
          rule_action_overrides = [
            {
              name = "HostingProviderIPList"
              action_to_use = { count = {} }
            }
          ]
        }
      },
    ]
    ...
  }
}
```


</details>


### DNS Record
Register a CNAME DNS record in a Route53 hosted zone that is present within the account, which can be public or private depending on the desired visibility type of the record.


<details><summary>Configuration Code</summary>

```hcl
dns_records = {
  "" = {
    # zone_name    = local.zone_private
    # private_zone = true
    zone_name    = local.zone_public
    private_zone = false
  }
}
```


</details>


### Access Log
Create S3 bucket and configure LoadBalancer access log in S3


<details><summary>Configuration Code</summary>

```hcl
enable_alb_logs        = true # Default: false
alb_logs_force_destroy = true # Default: false
alb_logs_lifecycle = [{
  id      = "move-to-onezone-ia"
  enabled = true
  transition = [{
    days          = 30
    storage_class = "ONEZONE_IA"
  }]
}]
```


</details>




## 📑 Inputs
| Name                                                         | Description                                                                                             | Type     | Default                                                   | Required |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------- | -------- |
| create                                                       | Controls whether to create the load balancer.                                                           | `bool`   | `true`                                                    | no       |
| create_security_group                                        | Specifies whether to create a new security group for the resource.                                      | `bool`   | `true`                                                    | no       |
| name                                                         | Name of the load balancer.                                                                              | `string` | `"${local.common_name}-${each.key}"`                      | no       |
| security_groups                                              | Security groups attached to the load balancer.                                                          | `list`   | `[module.security_group_alb[each.key].security_group_id]` | no       |
| drop_invalid_header_fields                                   | Drop invalid header fields for the load balancer.                                                       | `bool`   | `false`                                                   | no       |
| enable_deletion_protection                                   | Enables deletion protection for the load balancer.                                                      | `bool`   | `false`                                                   | no       |
| enable_http2                                                 | Enables HTTP/2 for the load balancer.                                                                   | `bool`   | `true`                                                    | no       |
| enable_cross_zone_load_balancing                             | Enables cross-zone load balancing.                                                                      | `bool`   | `false`                                                   | no       |
| https_listeners                                              | List of HTTPS listeners for the load balancer.                                                          | `list`   | `[]`                                                      | no       |
| listeners                                                    | List of HTTP or TCP listeners.                                                                          | `list`   | `null`                                                    | no       |
| idle_timeout                                                 | The idle timeout in seconds.                                                                            | `number` | `60`                                                      | no       |
| ip_address_type                                              | IP address type.                                                                                        | `string` | `"ipv4"`                                                  | no       |
| internal                                                     | Whether the load balancer is internal.                                                                  | `bool`   | `false`                                                   | no       |
| name_prefix                                                  | Prefix for the load balancer name.                                                                      | `string` | `null`                                                    | no       |
| load_balancer_type                                           | Type of load balancer (application, network).                                                           | `string` | `"application"`                                           | no       |
| minimum_load_balancer_capacity                               | Minimum capacity for a load balancer. Only valid for Load Balancers of type `application` or `network`. | `map`    | `null`                                                    | no       |
| timeouts                                                     | Timeout for updating the load balancer.                                                                 | `map`    | `null`                                                    | no       |
| access_logs                                                  | Access logs configuration.                                                                              | `map`    | `null`                                                    | no       |
| subnets                                                      | List of subnets for the load balancer.                                                                  | `list`   | `null`                                                    | no       |
| subnet_mapping                                               | Subnet mappings for the load balancer.                                                                  | `list`   | `null`                                                    | no       |
| lb_tags                                                      | Tags to apply to the load balancer.                                                                     | `map`    | `{}`                                                      | no       |
| target_groups                                                | Target groups for the load balancer.                                                                    | `map`    | `null`                                                    | no       |
| vpc_id                                                       | VPC ID where the load balancer will be deployed.                                                        | `string` | `null`                                                    | no       |
| enable_waf_fail_open                                         | Enables fail-open for the WAF.                                                                          | `bool`   | `false`                                                   | no       |
| desync_mitigation_mode                                       | Desync mitigation mode for the load balancer.                                                           | `string` | `"defensive"`                                             | no       |
| putin_khuylo                                                 | A custom variable.                                                                                      | `bool`   | `true`                                                    | no       |
| vpc_name                                                     | (optional) Custom VPC Name                                                                              | `string` | `"${local.common_name}"`                                  | no       |
| enable_zonal_shift                                           | Whether zonal shift is enabled                                                                          | `bool`   | `false`                                                   | no       |
| ipam_pools                                                   | The IPAM pools to use with the load balancer                                                            | `map`    | `null`                                                    | no       |
| additional_target_group_attachments                          | Additional target group attachments.                                                                    | `map`    | `null`                                                    | no       |
| associate_web_acl                                            | Whether to associate a WAF Web ACL.                                                                     | `bool`   | `false`                                                   | no       |
| client_keep_alive                                            | Client keep alive configuration.                                                                        | `string` | `null`                                                    | no       |
| connection_logs                                              | Connection logs configuration.                                                                          | `map`    | `null`                                                    | no       |
| health_check_logs                                            | Map containing health check logging configuration for application load balancers.                       | `map`    | `null`                                                    | no       |
| customer_owned_ipv4_pool                                     | Customer owned IPv4 pool.                                                                               | `string` | `null`                                                    | no       |
| default_port                                                 | Default port for the load balancer.                                                                     | `number` | `80`                                                      | no       |
| default_protocol                                             | Default protocol for the load balancer.                                                                 | `string` | `"HTTP"`                                                  | no       |
| enable_tls_version_and_cipher_suite_headers                  | Enable TLS version and cipher suite headers.                                                            | `bool`   | `null`                                                    | no       |
| enable_xff_client_port                                       | Enable XFF client port.                                                                                 | `bool`   | `null`                                                    | no       |
| enforce_security_group_inbound_rules_on_private_link_traffic | Enforce security group inbound rules on private link traffic.                                           | `bool`   | `null`                                                    | no       |
| route53_records                                              | Route53 records configuration.                                                                          | `map`    | `{}`                                                      | no       |
| web_acl_arn                                                  | Web ACL ARN to associate.                                                                               | `string` | `null`                                                    | no       |
| xff_header_processing_mode                                   | XFF header processing mode.                                                                             | `string` | `null`                                                    | no       |
| tags                                                         | A map of tags to assign to resources.                                                                   | `map`    | `{}`                                                      | no       |
| region                                                       | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration  | `string` | `null`                                                    | no       |







## ⚠️ Important Notes
- **⚠️ Security Group Creation:** The module creates security groups by default. Set `create_security_group = false` if you want to use existing security groups.
- **⚠️ WAF Integration:** WAF rules are automatically attached to ALB listeners when configured.
- **⚠️ DNS Records:** DNS records are created in Route53 hosted zones. Ensure the zone exists before creating records.
- **⚠️ Access Logs:** Access logs are stored in S3. Ensure proper S3 bucket permissions are configured.



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 