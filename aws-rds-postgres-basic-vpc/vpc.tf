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


## Routing

# Public Route Table
resource "aws_route_table" "public-rt" {
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

# Associate Routes with Subnets
resource "aws_route_table_association" "subnets_public_ra" {
  provider       = aws.aws_region
  count          = length(var.subnets_public_cidr)
  subnet_id      = element(aws_subnet.subnets_public.*.id, count.index)
  route_table_id = aws_route_table.public-rt.id

  depends_on = [aws_route_table.public-rt]
}