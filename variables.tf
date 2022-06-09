variable "aws_region" {
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
      cidr_block = ["10.159.94.0/23","10.189.0.0/23"]
    }
    ]
}

variable "rules_outbound_public_sg" {
   default = [
	  {
      port = 443
      proto = "tcp"
      cidr_block = ["0.0.0.0/0"]
    },
	  {
      port = 80
      proto = "tcp"
      cidr_block = ["0.0.0.0/0"]
    },
	  {
      port = 53
      proto = "tcp"
      cidr_block = ["0.0.0.0/0"]
    },
	{
      port = 53
      proto = "udp"
      cidr_block = ["0.0.0.0/0"]
    },
	  {
      port = 123
      proto = "tcp"
      cidr_block = ["0.0.0.0/0"]
    },
	  {
      port = 123
      proto = "udp"
      cidr_block = ["0.0.0.0/0"]
    },
    ]
}

variable "rules_inbound_public_sg_shr" {
   default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["10.159.94.0/23","10.189.0.0/23"]
    }
    ]
}

variable "rules_outbound_public_sg_shr" {
   default = [
	  {
      port = 443
      proto = "tcp"
      cidr_block = ["0.0.0.0/0"]
    },
	  {
      port = 80
      proto = "tcp"
      cidr_block = ["0.0.0.0/0"]
    },
	  {
      port = 53
      proto = "tcp"
      cidr_block = ["0.0.0.0/0"]
    },
	{
      port = 53
      proto = "udp"
      cidr_block = ["0.0.0.0/0"]
    },
	  {
      port = 123
      proto = "tcp"
      cidr_block = ["0.0.0.0/0"]
    },
	  {
      port = 123
      proto = "udp"
      cidr_block = ["0.0.0.0/0"]
    },
    ]
}

variable "rules_inbound_private_sg" {
    default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["10.159.94.0/23","10.189.0.0/23"]
    }
    ]
}

variable "rules_inbound_private_sg_shr" {
    default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["10.159.94.0/23","10.189.0.0/23"]
    }
    ]
}

variable "rules_outbound_private_sg" {
    default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["10.159.94.0/23","10.189.0.0/23"]
    }
    ]
}

variable "rules_outbound_private_sg_shr" {
    default = [
    {
      port = 0
      proto = "-1"
      cidr_block = ["10.159.94.0/23","10.189.0.0/23"]
    }
    ]
}


variable "il_external" {
	default = null
}

variable "fl_external" {
	default = null
}
