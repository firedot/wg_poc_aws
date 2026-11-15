# Read the default VPC
data "aws_vpc" "default" {
  default = true
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary" {
  vpc_id     = data.aws_vpc.default.id
  cidr_block = "172.16.0.0/16"
}

resource "aws_subnet" "private" {
  vpc_id            = data.aws_vpc.default.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "eu-central-1a"
  depends_on = [ aws_vpc_ipv4_cidr_block_association.secondary ]
  tags              = { Name = "wg-poc-server" }
}

resource "aws_security_group" "wg-proc-server" {
  name   = "wg-proc-server"
  vpc_id = data.aws_vpc.default.id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}