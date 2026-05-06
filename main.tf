data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"]
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "portal" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [module.portal_sg.security_group_id] # security_group_id : Terraform output type

  tags = {
    Name = "PoC Terraform"
  }
}

module "portal_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.0"

  vpc_id  = data.aws_vpc.default.id
  name    = "portal"
  ingress_rules = ["https-443-tcp","http-80-tcp"] # the rules from Terraform repo
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}