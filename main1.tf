provider "aws" {
  alias  = "east-1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "east-2"
  region = "us-east-2"
}

# VPC in us-east-1
resource "aws_vpc" "Myvpc_east1" {
  provider    = aws.east-1
  cidr_block  = "10.0.0.0/16"
  tags = {
    Name = "vpc-us-east-1"
  }
}

# Subnet in us-east-1
resource "aws_subnet" "subnet_east_1" {
  provider           = aws.east-1
  vpc_id             = aws_vpc.Myvpc_east1.id
  cidr_block         = "10.0.1.0/24"
  
  tags = {
    Name = "subnet-us-east-1"
  }
}

# Internet Gateway in us-east-1
resource "aws_internet_gateway" "igw_east_1" {
  provider = aws.east-1
  vpc_id   = aws_vpc.Myvpc_east1.id
  tags = {
    Name = "igw-us-east-1"
  }
}

# Route Table in us-east-1
resource "aws_route_table" "rt_east_1" {
  provider = aws.east-1
  vpc_id   = aws_vpc.Myvpc_east1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_east_1.id
  }
  tags = {
    Name = "rt-us-east-1"
  }
}

# Route Table Association in us-east-1
resource "aws_route_table_association" "rta_east_1" {
  provider      = aws.east-1
  subnet_id     = aws_subnet.subnet_east_1.id
  route_table_id = aws_route_table.rt_east_1.id
}

# EC2 instance in us-east-1
resource "aws_instance" "My_ins1" {
  provider      = aws.east-1
  ami           = "ami-04b70fa74e45c3909" # Example AMI ID, Please do update with a valid one
  instance_type = "t2.small"
  subnet_id     = aws_subnet.subnet_east_1.id
  tags = {
    Name = "instance-us-east-1"
  }
}

# VPC in us-east-2
resource "aws_vpc" "Myvpc_east2" {
  provider    = aws.east-2
  cidr_block  = "10.1.0.0/16"
  tags = {
    Name = "vpc-us-east-2"
  }
}

# Subnet in us-east-2
resource "aws_subnet" "subnet_east_2" {
  provider           = aws.east-2
  vpc_id             = aws_vpc.Myvpc_east2.id
  cidr_block         = "10.1.1.0/24"
  
  tags = {
    Name = "subnet-us-east-2a"
  }
}

# Internet Gateway in us-east-2
resource "aws_internet_gateway" "igw_east_2" {
  provider = aws.east-2
  vpc_id   = aws_vpc.Myvpc_east2.id
  tags = {
    Name = "igw-us-east-2"
  }
}

# Route Table in us-east-2
resource "aws_route_table" "rt_east_2" {
  provider = aws.east-2
  vpc_id   = aws_vpc.Myvpc_east2.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_east_2.id
  }
  tags = {
    Name = "rt-us-east-2"
  }
}

# Route Table Association in us-east-2
resource "aws_route_table_association" "rta_east_2" {
  provider      = aws.east-2
  subnet_id     = aws_subnet.subnet_east_2.id
  route_table_id = aws_route_table.rt_east_2.id
}

# EC2 instance in us-east-2
resource "aws_instance" "My_ins2" {
  provider      = aws.east-2
  ami           = "ami-09040d770ffe2229g" # Example AMI ID, Please do update with a valid one
  instance_type = "t2.small"
  subnet_id     = aws_subnet.subnet_east_2.id
  tags = {
    Name = "instance-us-east-2"
  }
}

# VPC Peering Connection
resource "aws_vpc_peering_connection" "vpc_peering" {
  provider           = aws.east-1
  vpc_id             = aws_vpc.Myvpc_east1.id
  peer_vpc_id        = aws_vpc.Myvpc_east2.id
  peer_region        = "us-east-2"
  auto_accept        = false
  tags = {
    Name = "us-east-1-to-us-east-2"
  }
}

# Accept the peering connection in us-east-2
resource "aws_vpc_peering_connection_accepter" "peer_accept" {
  provider                  = aws.east-2
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  auto_accept               = true
  tags = {
    Name = "us-east-2-accept-peer"
  }
}

# Route table for VPC in us-east-1 to peer
resource "aws_route" "route_east_1" {
  provider                  = aws.east-1
  route_table_id            = aws_route_table.rt_east_1.id
  destination_cidr_block    = aws_vpc.Myvpc_east2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

# Route table for VPC in us-east-2 to peer
resource "aws_route" "route_us_east_2" {
  provider                  = aws.east-2
  route_table_id            = aws_route_table.rt_east_2.id
  destination_cidr_block    = aws_vpc.Myvpc_east1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}
