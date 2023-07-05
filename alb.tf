#tfsec:ignore:aws-elb-alb-not-public
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "8.7.0"
  internal = false
  name = join("-", [local.name, "nginx", "alb"])

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  #   Attach rules to the created security group
  security_group_rules = {
    ingress_all_http = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP web traffic"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_all_icmp = {
      type        = "ingress"
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "ICMP"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # # See notes in README (ref: https://github.com/terraform-providers/terraform-provider-aws/issues/7987)
  # access_logs = {
  #   bucket = module.log_bucket.s3_bucket_id
  # }

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },

    // Unable to enable https listener in AWS Sandbox for the time being
    #   https_listeners = [
    #     {
    #       port               = 443
    #       protocol           = "HTTPS"
    #       certificate_arn    = module.acm.acm_certificate_arn
    #       target_group_index = 1
    #     },
    # Authentication actions only allowed with HTTPS
  ]

  target_groups = [
    {
      name_prefix      = "tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  tags = local.tags
}
