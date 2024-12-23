resource "aws_vpc" "SEC-PRD-VPC" {
  cidr_block  = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = "SEC-PRD-VPC"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "SEC-PUB-2A" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  cidr_block = "10.10.7.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "SEC-PUB-2A"
  }
}

resource "aws_subnet" "SEC-PUB-2C" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  cidr_block = "10.10.8.0/24"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "SEC-PUB-2C"
  }
}

resource "aws_subnet" "SEC-PRI-WEB-2A" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  cidr_block = "10.10.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "SEC-PRI-WEB-2A"
  }
}

resource "aws_subnet" "SEC-PRI-WEB-2C" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  cidr_block = "10.10.110.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "SEC-PRI-WEB-2C"
  }
}

resource "aws_subnet" "SEC-PRI-APP-2A" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  cidr_block = "10.10.20.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "SEC-PRI-APP-2A"
  }
}

resource "aws_subnet" "SEC-PRI-APP-2C" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  cidr_block = "10.10.120.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "SEC-PRI-APP-2C"
  }
}

resource "aws_subnet" "SEC-PRI-DB-2A" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  cidr_block = "10.10.30.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "SEC-PRI-DB-2A"
  }
}

resource "aws_subnet" "SEC-PRI-DB-2C" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  cidr_block = "10.10.130.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "SEC-PRI-DB-2C"
  }
}


resource "aws_internet_gateway" "SEC-PRD-IGW" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  tags = {
    Name = "SEC-PRD-IGW"
  }
}

resource "aws_route_table" "SEC-PRD-RT-PUB" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.SEC-PRD-IGW.id
  }
  tags = {
    Name = "SEC-PRD-RT-PUB"
  }
}

resource "aws_route_table" "SEC-PRD-RT-PRI-2A" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_instance.Bastion-Server.primary_network_interface_id
  }
  tags = {
    Name = "SEC-PRD-RT-PRI-2A"
  }
}

resource "aws_route_table" "SEC-PRD-RT-PRI-2C" {
  vpc_id = aws_vpc.SEC-PRD-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_instance.Bastion-Server.primary_network_interface_id
  }
  tags = {
    Name = "SEC-PRD-RT-PRI-2C"
  }
}

resource "aws_route_table_association" "SEC-PUB-2A_association" {
  subnet_id = aws_subnet.SEC-PUB-2A.id
  route_table_id = aws_route_table.SEC-PRD-RT-PUB.id
}

resource "aws_route_table_association" "SEC-PUB-2C_association" {
  subnet_id = aws_subnet.SEC-PUB-2C.id
  route_table_id = aws_route_table.SEC-PRD-RT-PUB.id
}

resource "aws_route_table_association" "SEC-PRI-WEB-2A_association" {
  subnet_id = aws_subnet.SEC-PRI-WEB-2A.id
  route_table_id = aws_route_table.SEC-PRD-RT-PRI-2A.id
}

resource "aws_route_table_association" "SEC-PRI-WEB-2C_association" {
  subnet_id = aws_subnet.SEC-PRI-WEB-2C.id
  route_table_id = aws_route_table.SEC-PRD-RT-PRI-2C.id
}

resource "aws_route_table_association" "SEC-PRI-APP-2A_association" {
  subnet_id = aws_subnet.SEC-PRI-APP-2A.id
  route_table_id = aws_route_table.SEC-PRD-RT-PRI-2A.id
}

resource "aws_route_table_association" "SEC-PRI-APP-2C_association" {
  subnet_id = aws_subnet.SEC-PRI-APP-2C.id
  route_table_id = aws_route_table.SEC-PRD-RT-PRI-2C.id
}

resource "aws_route_table_association" "SEC-PRI-DB-2A_association" {
  subnet_id = aws_subnet.SEC-PRI-DB-2A.id
  route_table_id = aws_route_table.SEC-PRD-RT-PRI-2A.id
}

resource "aws_route_table_association" "SEC-PRI-DB-2C_association" {
  subnet_id = aws_subnet.SEC-PRI-DB-2C.id
  route_table_id = aws_route_table.SEC-PRD-RT-PRI-2C.id
}