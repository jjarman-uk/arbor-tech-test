module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = join("-", [local.name, "vpc"])
  cidr = var.vpc_cidr

  azs             = ["${local.region}a", "${local.region}b"]
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_ipv6 = false

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
      Name = join("-", [local.name, "private"])
  }

  public_subnet_tags_per_az = {
    "${local.region}a" = {
      "availability-zone" = "${local.region}a"
    }
  }

  private_subnet_tags = {
    Name = join("-", [local.name, "private"])
  }

  private_subnet_tags_per_az = {
    "${local.region}a" = {
      "availability-zone" = "${local.region}a"
    }
  }

  tags = local.tags

  vpc_tags = {
    Name = local.name
  }
}

resource "aws_cloudwatch_log_group" "vpn_endpoint_logs" {
  name = format("%s-%s", var.environment, "arbor-test-endpoint-logs")
  tags = local.tags
}

resource "aws_cloudwatch_log_stream" "vpn_endpoint_stream" {
  name           = format("%s-%s", var.environment, "arbor-test-endpoint-stream")
  log_group_name = aws_cloudwatch_log_group.vpn_endpoint_logs.name
}

// Use the below to create certifications for enabling TLS


# resource "aws_acm_certificate" "cert" {
#   domain_name       = format("%s.%s", var.environment, "test.arbor.com")
#   validation_method = "DNS"

#   tags = {
#     Environment = var.environment
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# data "aws_route53_zone" "vpntest" {
#   name         = "vpntest.infinityworks.com"
#   private_zone = false
# }

# resource "aws_route53_record" "vpntest" {
#   for_each = {
#     for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.vpntest.zone_id
# }

# resource "aws_acm_certificate_validation" "vpn_validation" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.vpntest : record.fqdn]
# }