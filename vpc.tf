locals {
  common_tags = {
    source = "Dojo VSCode Box"
  }
  env_name = "dixneuf19"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.common_tags,
  { Name = "Dojo VR" })
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "subnet_primary" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags                    = local.common_tags
}


resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.common_tags
}

resource "aws_default_route_table" "default_route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = local.common_tags
}
