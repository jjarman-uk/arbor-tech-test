module "asg" {
  name    = join("-", [local.name, "asg"])
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.10.0"

  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 2
  vpc_zone_identifier       = module.vpc.private_subnets
  target_group_arns         = module.alb.target_group_arns
  health_check_type         = "ELB"
  health_check_grace_period = 300
  default_cooldown          = 300
  enabled_metrics           = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  # Launch template
  launch_template_name        = join("-", [local.name, "launch"])
  launch_template_description = "Launch template for nginx web server"
  update_default_version      = true

  image_id          = data.aws_ami.amazon.image_id
  user_data         = filebase64("${path.module}/templates/userdata.sh")
  instance_type     = "t3.micro"
  ebs_optimized     = true
  enable_monitoring = true

  # IAM role & instance profile
  create_iam_instance_profile = true
  iam_role_name               = join("-", [local.name, "role"])
  iam_role_path               = "/ec2/"
  iam_role_description        = "Nginx IAM instance role"
  iam_role_tags = {
    CustomIamRole = "Yes"
  }
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 32
  }

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [aws_security_group.nginx.id]
    },
  ]


  tags = local.tags
}

resource "aws_security_group" "nginx" {
  name        = join("-", [local.name, "nginx", "security", "group"])
  description = "Security group for Nginx web server"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    # cidr_blocks = ["0.0.0.0/0"] # Adjust as per your requirements
    security_groups = [module.alb.security_group_id]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    # cidr_blocks = ["0.0.0.0/0"] # Adjust as per your requirements
    security_groups = [module.alb.security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

