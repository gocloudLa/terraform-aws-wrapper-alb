/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}


/*----------------------------------------------------------------------*/
/* ALB | Variable Definition                                            */
/*----------------------------------------------------------------------*/

variable "alb_parameters" {
  type        = any
  description = ""
  default     = {}
}

variable "alb_defaults" {
  description = "Map of default values which will be used for each item."
  type        = any
  default     = {}
}

variable "aws_sns_topic_alerts" {
  description = ""
  type        = string
  default     = ""
}
