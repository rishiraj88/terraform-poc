variable "instance_type" {
  description = "class of EC2 instance"
  default     = "t3.nano"
}

variable "ami_filter" {
  description = "name filter and owner for AMI"

  type    = object ({
    name  = string
    owner = string
  })

  default = {
    name  = "bitnami-tomcat-*-x86_64-hvm-ebs-nami"
    owner = "979382823631" # Bitnami, the friends
  }
}

variable "environment" {
  description = "deployment environment for dev activities"

  type        = object ({
    name           = string
    network_prefix = string
  })
  default = {
    name           = "dev"
    network_prefix = "10.0"
  }
}

variable "instances_min" {
  description = "minimum number of instances for ASG"
  default     = 1
}

variable "instances_max" {
  description = "maximum number of instances  for ASG"
  default     = 2
}





