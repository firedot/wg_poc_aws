# Read the default VPC
data "aws_vpc" "default" {
  default = true
}

# Default (public) subnet in eu-central-1a, hosts the NAT GW
data "aws_subnet" "default_public" {
  vpc_id            = data.aws_vpc.default.id
  default_for_az    = true
  availability_zone = "eu-central-1a"
}

#  additional address range to the VPC
resource "aws_vpc_ipv4_cidr_block_association" "secondary" {
  vpc_id     = data.aws_vpc.default.id
  cidr_block = "172.16.0.0/16"
}

# private subnet from the network range intended to be used by the server
resource "aws_subnet" "private" {
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "eu-central-1a"
  depends_on        = [aws_vpc_ipv4_cidr_block_association.secondary]
  tags              = { Name = "wg-poc-private_subnet" }
}

# Server SG: no ingress rules; all egress allowed
resource "aws_security_group" "wg-poc-server" {
  name   = "wg-poc-server"
  vpc_id = data.aws_vpc.default.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = { Name = "wg-poc-SG-server" }
}

# elastic IP to be used by the NAT GW
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "wg-poc-EIP-NAT-GW" }
}

# NAT GW to be used by the private subnet in which the server resides
resource "aws_nat_gateway" "wg-poc-server" {
  allocation_id = aws_eip.nat.id
  subnet_id     = data.aws_subnet.default_public.id
  tags          = { Name = "wg-poc-NAT_GW" }
}

# Private route table: default route through the NAT GW
resource "aws_route_table" "wg-poc-server" {
  vpc_id = data.aws_vpc.default.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.wg-poc-server.id
  }
  tags = { Name = "wg-poc-route_table" }
}

# Attach the private route table to the server's subnet
resource "aws_route_table_association" "wg-poc-server" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.wg-poc-server.id
}

# Relay SG: Rules are defined as separate resources below
resource "aws_security_group" "wg-poc-relay" {
  name   = "wg-poc-relay"
  vpc_id = data.aws_vpc.default.id
  tags   = { Name = "wg-poc-SG-relay" }
}

# Relay egress: all traffic (no inline rules; separate resource)
resource "aws_vpc_security_group_egress_rule" "relay_all" {
  security_group_id = aws_security_group.wg-poc-relay.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  tags              = { Name = "wg-poc-SG-r_egress-relay" }
}

# Relay ingress: WireGuard (UDP 51820) from anywhere
resource "aws_vpc_security_group_ingress_rule" "allow_udp_wireguard" {
  security_group_id = aws_security_group.wg-poc-relay.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 51820
  ip_protocol       = "udp"
  to_port           = 51820
  tags              = { Name = "wg-poc-SG-r_ingress-relay" }
}