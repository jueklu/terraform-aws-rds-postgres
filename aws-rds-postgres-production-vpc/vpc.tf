# VPC "10.10.0.0/16"
resource "aws_vpc" "vpc" {
  provider              = aws.aws_region
  cidr_block            = var.vpc_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true

  tags = {
    Name                = "${var.vpc_name}"
    Env                 = "Production"
  }
}

## Subnets

# Public Subnets (Loop)
resource "aws_subnet" "subnets_public" {
  provider                  = aws.aws_region
  count                     = length(var.subnets_public_cidr)
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = element(var.subnets_public_cidr, count.index)
  availability_zone         = element(var.subnets_public_azs, count.index)
  map_public_ip_on_launch   = true

  tags = {
    Name                    = "${var.vpc_name} Subnet-Public-${count.index + 1}"
    Env                     = "Production"
  }
}

# Private Subnets (Loop)
resource "aws_subnet" "subnets_private" {
  provider                  = aws.aws_region
  count                     = length(var.subnets_private_cidr)
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = element(var.subnets_private_cidr, count.index)
  availability_zone         = element(var.subnets_private_azs, count.index)

  tags = {
    Name                    = "${var.vpc_name} Subnet-Private-${count.index + 1}"
    Env                     = "Production"
  }
}

## Gateways

# Internet Gateway
resource "aws_internet_gateway" "vpc_igw" {
  provider      = aws.aws_region
  vpc_id        = aws_vpc.vpc.id

  depends_on = [aws_vpc.vpc]

  tags = {
    Name        = "${var.vpc_name} IGW"
    Env         = "Production"
  }
}

# Elastic IPs (EIP) for NAT Gateways (Loop)
resource "aws_eip" "nat_gw_eip" {
  provider  = aws.aws_region
  count     = length(var.subnets_public_cidr)
  domain    = "vpc"

  tags = {
    Name = "VPC NAT-GW EIP-${count.index + 1}"
    Env  = "Production"
  }
}

# NAT Gateways (Loop)
resource "aws_nat_gateway" "nat_gw" {
  provider      = aws.aws_region
  count         = length(var.subnets_public_cidr)
  allocation_id = element(aws_eip.nat_gw_eip[*].id, count.index)
  subnet_id     = aws_subnet.subnets_public[count.index].id

  depends_on = [aws_internet_gateway.vpc_igw]

  tags = {
    Name = "VPC NAT-GW-${count.index + 1}"
    Env  = "Production"
  }
}


## Routing

# Public Route Table
resource "aws_route_table" "public_rt" {
  provider = aws.aws_region
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }

  depends_on = [
    aws_vpc.vpc,
    aws_internet_gateway.vpc_igw
    ]

  tags = {
    Name        = "${var.vpc_name} Public Route Table"
    Env         = "Production"
  }
}

# Private Route Tables (Loop)
resource "aws_route_table" "private_rt" {
  provider = aws.aws_region
  count    = length(var.subnets_private_cidr)
  vpc_id   = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gw[*].id, count.index)
  }

  tags = {
    Name = "${var.vpc_name} Private Route Table-${count.index + 1}"
    Env  = "Production"
  }
}


# Associate Route Tables with Public Subnets
resource "aws_route_table_association" "subnets_public_ra" {
  provider       = aws.aws_region
  count          = length(var.subnets_public_cidr)
  subnet_id      = element(aws_subnet.subnets_public.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id

  depends_on = [aws_route_table.public_rt]
}

# Associate Route Tables with Private Subnets
resource "aws_route_table_association" "private_rta" {
  provider       = aws.aws_region
  count          = length(var.subnets_private_cidr)
  subnet_id      = aws_subnet.subnets_private[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}