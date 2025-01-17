# EC2 Instances in Public Subnets (Loop)
resource "aws_instance" "vm" {
  provider                  = aws.aws_region
  count                     = length(var.subnets_public_cidr) # Create as many instances as subnets
  ami                       = var.ami_id
  instance_type             = "t3.small"
  subnet_id                 = aws_subnet.subnets_public[count.index].id
  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.sg_ec2.id]

  depends_on = [
    aws_vpc.vpc,
    aws_security_group.sg_ec2
  ]

  tags = {
    Name = "VM Public Subnet ${count.index + 1}"
    Env  = "Production"
  }
}


# Security Group for SSH Access and Ping
resource "aws_security_group" "sg_ec2" {
  provider = aws.aws_region
  name        = "SG"
  description = "Security group for SSH access and ping"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow ping"
    from_port   = 8
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [aws_vpc.vpc]

  tags = {
    Name = "SG"
    Env  = "Production"
  }
}