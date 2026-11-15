# Read the ddefault VPC
data "aws_vpc" "default" {
  default = true
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary" {
  vpc_id     = data.aws_vpc.default.id
  cidr_block = "172.16.0.0/16"
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc_ipv4_cidr_block_association.secondary.id
  cidr_block = "172.16.1.0/24"
  tags       = { Name = "wg-poc-server" }
}


