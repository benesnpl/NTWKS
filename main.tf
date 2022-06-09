provider "aws" {
  region = var.aws_region
}

#VPC Creation - FW

resource "aws_vpc" "fw_vpc" {
  cidr_block       					         = var.vpcip_fw
  tags = {
    Name = join("", [var.coid, "-us-E-FW"])
  }
}

#VPC Creation - SHS

resource "aws_vpc" "shr_vpc" {
  cidr_block       					         = var.vpcip_shr
  tags = {
    Name = join("", [var.coid, "-us-E-SHR"])
  }
}

#Subnet Creation - FW

resource "aws_subnet" "public" {
  count = length(var.subnets_cidr_public)
  vpc_id = aws_vpc.fw_vpc.id
  cidr_block = element(var.subnets_cidr_public,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = join("", [var.coid, "-us-E-FW-public-AZ${count.index+1}"])
  }
}

resource "aws_subnet" "Private" {
  count = length(var.subnets_cidr_private)
  vpc_id = aws_vpc.fw_vpc.id
  cidr_block = element(var.subnets_cidr_private,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = join("", [var.coid, "-us-E-FW-private-AZ${count.index+1}"])
  }
}

#Subnet Creation - SHR

resource "aws_subnet" "public_shr" {
  count = length(var.subnets_cidr_public_shr)
  vpc_id = aws_vpc.shr_vpc.id
  cidr_block = element(var.subnets_cidr_public_shr,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = join("", [var.coid, "-us-E-SHR-public-AZ${count.index+1}"])
  }
}

resource "aws_subnet" "Private_shr" {
  count = length(var.subnets_cidr_private_shr)
  vpc_id = aws_vpc.shr_vpc.id
  cidr_block = element(var.subnets_cidr_private_shr,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = join("", [var.coid, "-us-E-SHR-private-AZ${count.index+1}"])
  }
}

#TGW Creation

resource "aws_ec2_transit_gateway" "fw_tgw" {
  description = "TGW"
  auto_accept_shared_attachments = "enable"
  tags = {
   Name = join("", [var.coid, "-TGW"])
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-main" {
  depends_on = [aws_ec2_transit_gateway.fw_tgw]
  subnet_ids         = "${aws_subnet.Private.*.id}"
  transit_gateway_id = aws_ec2_transit_gateway.fw_tgw.id
  vpc_id             = aws_vpc.fw_vpc.id
  appliance_mode_support = "enable"
  tags = {
   Name = join("", [var.coid, "-Hub-VPC"])
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-main_shr" {
  depends_on = [aws_ec2_transit_gateway.fw_tgw]
  subnet_ids         = "${aws_subnet.Private_shr.*.id}"
  transit_gateway_id = aws_ec2_transit_gateway.fw_tgw.id
  vpc_id             = aws_vpc.shr_vpc.id
  appliance_mode_support = "enable"
  tags = {
   Name = join("", [var.coid, "-SHR-VPC"])
  }
}

#IGW Creation - FW

resource "aws_internet_gateway" "main_igw" {
  depends_on = [aws_ec2_transit_gateway.fw_tgw,aws_internet_gateway.main_igw]
  vpc_id = aws_vpc.fw_vpc.id
  tags = {
    Name = join("", [var.coid, "-FW-IGW"])
  }
}

#IGW Creation - SHS

resource "aws_internet_gateway" "main_igw_shr" {
  depends_on = [aws_ec2_transit_gateway.fw_tgw,aws_internet_gateway.main_igw]
  vpc_id = aws_vpc.shr_vpc.id
  tags = {
    Name = join("", [var.coid, "-SHR-IGW"])
  }
}

#RT Public - FW

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.fw_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
  
  
  tags = {
    Name = ("keyf-us-e-Public-fw-rt")
  }
}

#RT Public - SHR

resource "aws_route_table" "public_rt_shr" {
  depends_on = [aws_ec2_transit_gateway.fw_tgw,aws_internet_gateway.main_igw_shr]
  vpc_id = aws_vpc.shr_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw_shr.id
  }
  
  
  tags = {
    Name = ("keyf-us-e-Public-shr-rt")
  }
}

#Private_rt_fw

resource "aws_route_table" "private_rt" {
  depends_on = [aws_internet_gateway.main_igw,aws_ec2_transit_gateway.fw_tgw,aws_vpn_connection.Miami]
  vpc_id = aws_vpc.fw_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_ec2_transit_gateway.fw_tgw.id
  }
  
  
  tags = {
    Name = ("keyf-us-e-Private-fw-rt")
  }
}

#Private_rt_shr

resource "aws_route_table" "private_rt_shr" {
  depends_on = [aws_internet_gateway.main_igw_shr,aws_ec2_transit_gateway.fw_tgw,aws_vpn_connection.Miami]
  vpc_id = aws_vpc.shr_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_ec2_transit_gateway.fw_tgw.id
  }
  
  
  tags = {
    Name = ("keyf-us-e-Private-shr-rt")
  }
}

resource "aws_route_table_association" "prvt" {
  depends_on = [aws_route_table.private_rt]
  count = length(var.subnets_cidr_private)
  subnet_id      = element(aws_subnet.Private.*.id,count.index)
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "prvt_shr" {
  depends_on = [aws_route_table.private_rt_shr]
  count = length(var.subnets_cidr_private_shr)
  subnet_id      = element(aws_subnet.Private_shr.*.id,count.index)
  route_table_id = aws_route_table.private_rt_shr.id
}

resource "aws_route_table_association" "public" {
  depends_on = [aws_route_table.public_rt]
  count = length(var.subnets_cidr_public)
  subnet_id      = element(aws_subnet.public.*.id,count.index)
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_shr" {
  depends_on = [aws_route_table.public_rt_shr]
  count = length(var.subnets_cidr_public_shr)
  subnet_id      = element(aws_subnet.public_shr.*.id,count.index)
  route_table_id = aws_route_table.public_rt_shr.id
}

 resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "public SG"
  vpc_id      = aws_vpc.fw_vpc.id

  dynamic "ingress" {
    for_each = var.rules_inbound_public_sg
    content {
      from_port = ingress.value["port"]
      to_port = ingress.value["port"]
      protocol = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_block"]
    }
  }
  dynamic "egress" {
    for_each = var.rules_outbound_public_sg
    content {
      from_port = egress.value["port"]
      to_port = egress.value["port"]
      protocol = egress.value["proto"]
      cidr_blocks = egress.value["cidr_block"]
    }
  }
  tags = {
    Name = join("", [var.coid, "-FW-Public-SG"])
  }
}

 resource "aws_security_group" "public_sg_shr" {
  name        = "public_sg_shr"
  description = "public SG_SHR"
  vpc_id      = aws_vpc.shr_vpc.id

  dynamic "ingress" {
    for_each = var.rules_inbound_public_sg_shr
    content {
      from_port = ingress.value["port"]
      to_port = ingress.value["port"]
      protocol = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_block"]
    }
  }
  dynamic "egress" {
    for_each = var.rules_outbound_public_sg_shr
    content {
      from_port = egress.value["port"]
      to_port = egress.value["port"]
      protocol = egress.value["proto"]
      cidr_blocks = egress.value["cidr_block"]
    }
  }
  tags = {
    Name = join("", [var.coid, "-SHR-Public-SG"])
  }
}

 resource "aws_security_group" "private_sg" {
  name        = "private_sg"
  description = "Private SG"
  vpc_id      = aws_vpc.fw_vpc.id

  dynamic "ingress" {
    for_each = var.rules_inbound_private_sg
    content {
      from_port = ingress.value["port"]
      to_port = ingress.value["port"]
      protocol = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_block"]
    }
  }
  dynamic "egress" {
    for_each = var.rules_outbound_private_sg
    content {
      from_port = egress.value["port"]
      to_port = egress.value["port"]
      protocol = egress.value["proto"]
      cidr_blocks = egress.value["cidr_block"]
    }
  }
  tags = {
    Name = join("", [var.coid, "-FW-Private-sg"])
  }
} 

 resource "aws_security_group" "private_sg_shr" {
  name        = "private_sg_shr"
  description = "Private SG_SHR"
  vpc_id      = aws_vpc.shr_vpc.id

  dynamic "ingress" {
    for_each = var.rules_inbound_private_sg_shr
    content {
      from_port = ingress.value["port"]
      to_port = ingress.value["port"]
      protocol = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_block"]
    }
  }
  dynamic "egress" {
    for_each = var.rules_outbound_private_sg_shr
    content {
      from_port = egress.value["port"]
      to_port = egress.value["port"]
      protocol = egress.value["proto"]
      cidr_blocks = egress.value["cidr_block"]
    }
  }
  tags = {
    Name = join("", [var.coid, "-SHR-Private-sg"])
  }
} 

resource "aws_customer_gateway" "oakbrook" {
  bgp_asn    = 65000
  ip_address = var.il_external
  type       = "ipsec.1"

  tags = {
    Name = join("", [var.coid, "-Oakbrook-CGW"])
  }
}

resource "aws_customer_gateway" "miami" {
  bgp_asn    = 65000
  ip_address = var.fl_external
  type       = "ipsec.1"

  tags = {
    Name = join("", [var.coid, "-Miami-CGW"])
  }
} 

  resource "aws_vpn_connection" "Oakbrook" {
  transit_gateway_id  = aws_ec2_transit_gateway.fw_tgw.id
  customer_gateway_id = aws_customer_gateway.oakbrook.id
  type                = "ipsec.1"
  static_routes_only  = true
  tags = {
    Name = join("", [var.coid, "-Oakbrook-ipsec"])
  }
  
}

resource "aws_vpn_connection" "Miami" {
  transit_gateway_id  = aws_ec2_transit_gateway.fw_tgw.id
  customer_gateway_id = aws_customer_gateway.miami.id
  type                = "ipsec.1"
  static_routes_only  = true
  tags = {
    Name = join("", [var.coid, "-Miami-ipsec"])
  }
}

data "aws_ec2_transit_gateway_vpn_attachment" "oak_attach" {
  transit_gateway_id = aws_ec2_transit_gateway.fw_tgw.id
  vpn_connection_id  = aws_vpn_connection.Oakbrook.id
}

data "aws_ec2_transit_gateway_vpn_attachment" "miami_attach" {
  transit_gateway_id = aws_ec2_transit_gateway.fw_tgw.id
  vpn_connection_id  = aws_vpn_connection.Miami.id
}

resource "aws_ec2_transit_gateway_route" "oak_vpn" {
  destination_cidr_block         = "10.159.94.0/23"
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpn_attachment.oak_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.fw_tgw.association_default_route_table_id
  blackhole                      = false
}

resource "aws_ec2_transit_gateway_route" "mia_vpn" {
  destination_cidr_block         = "10.189.0.0/23"
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_vpn_attachment.miami_attach.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.fw_tgw.association_default_route_table_id
  blackhole                      = false
}
