provider "aws" {
  region = "eu-central-1"
}


data "aws_availability_zones" "available" {}

data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_ami" "aws_linux_2_latest" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

//==========================EC2==============================================

resource "aws_instance" "my_ubuntu_server" {
  ami                    = data.aws_ami.aws_linux_2_latest.id
  instance_type          = var.EC2_type
  key_name               = "mykey_ssh" # указываем ключ который хотим  использовать для доступа к istance
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = merge(var.common_tags, { Name = "${var.env}-EC2 Ubuntu" })
}

resource "aws_instance" "my_aws_server" {
  ami                    = data.aws_ami.ubuntu_latest.id
  instance_type          = var.EC2_type
  key_name               = "mykey_ssh" # указываем ключ который хотим  использовать для доступа к istance
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = merge(var.common_tags, { Name = "${var.env}-EC2 AWS" })
}



//==========================VPC==============================================


resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.common_tags, { Name = "${var.env}-igw" })
}

#-------------Public Subnets and Routing----------------------------------------
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(var.common_tags, { Name = "${var.env}-public-${count.index + 1}" })
}


resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(var.common_tags, { Name = "${var.env}-route-public-subnets" })
}

resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
}


//==========================SG==============================================


resource "aws_security_group" "my_sg" {
  name        = "My ${var.env} SG"
  description = "Allow web trafic + ssh"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.allow_ingress_ports_for_all
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "ingress" {
    for_each = var.allow_ingress_ports_for_some_IPs
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.IPs_to_allow_acces_from
    }
  }

  egress {
    description = "for all outgoing traffics"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Все протоколы
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.common_tags, { Name = "My ${var.env}-SG" })
}
