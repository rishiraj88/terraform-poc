data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter.name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_filter.owner]
}

module "portal_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.environment.name
  cidr = "${var.environment.network_prefix}.0.0/16"

  azs             = ["eu-central-1a","eu-central-1b","eu-central-1c"]
  public_subnets  = ["${var.environment.network_prefix}.101.0/24", "${var.environment.network_prefix}.102.0/24", "${var.environment.network_prefix}.103.0/24"]

  enable_nat_gateway = true
  #enable_vpn_gateway = true
  
  tags = {
    Terraform = "true"
    Environment = var.environment.name
  }
}

module "portal_autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  name = "portal"

  min_size            = var.instances_min
  max_size            = var.instances_max
  vpc_zone_identifier = module.portal_vpc.public_subnets
  target_group_arns   = module.portal_alb.target_group_arns
  security_groups     = [module.portal_sg.security_group_id]
  instance_type       = var.instance_type
  image_id            = data.aws_ami.app_ami.id
}

module "portal_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "portal-alb"

  load_balancer_type = "application"

  vpc_id             = module.portal_vpc.vpc_id
  subnets            = module.portal_vpc.public_subnets
  security_groups    = [module.portal_sg.security_group_id]

  target_groups = [
    {
      name_prefix      = "portal-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = var.environment.name
  }
}

module "portal_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.0"

  vpc_id  = module.portal_vpc.vpc_id

  name    = "portal"
  ingress_rules = ["https-443-tcp","http-80-tcp"] # the rules from Terraform repo
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
