ariable "aws_region" {
	default = null
}

variable "vpcip_fw" {
	default = null
}

variable "vpcip_shr" {
	default = null
}

variable "coid" {
	default = null
}

variable "azs" {
	type = list
	default = null
}

variable "subnets_cidr_public" {
	type = list
	default = null
}

variable "subnets_cidr_private" {
	type = list
	default = null
}

variable "subnets_cidr_public_shr" {
	type = list
	default = null
}

variable "subnets_cidr_private_shr" {
	type = list
	default = null
}





variable "rules_inbound_public_sg" {
  default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["0.0.0.0/0"]
    }
    ]
}

variable "rules_outbound_public_sg" {
  default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["0.0.0.0/0"]
    }
    ]
}

variable "rules_inbound_public_sg_shr" {
  default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["0.0.0.0/0"]
    }
    ]
}

variable "rules_outbound_public_sg_shr" {
  default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["0.0.0.0/0"]
    }
    ]
}

variable "rules_inbound_private_sg" {
  default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["10.0.0.0/8","192.168.0.0/16","172.16.0.0/12","100.70.0.0/15"]
    }
    ]
}

variable "rules_inbound_private_sg_shr" {
  default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["10.0.0.0/8","192.168.0.0/16","172.16.0.0/12","100.70.0.0/15"]
    }
    ]
}

variable "rules_outbound_private_sg" {
  default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["0.0.0.0/0"]
    }
    ]
}

variable "rules_outbound_private_sg_shr" {
  default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["0.0.0.0/0"]
    }
    ]
}


variable "il_external" {
	default = null
}

variable "fl_external" {
	default = null
}
