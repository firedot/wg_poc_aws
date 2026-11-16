# Latest official Debian 13 (amd64) AMI, published by Debian's AWS account
data "aws_ami" "debian" {
  most_recent = true
  owners      = ["136693071363"] # Debian

  filter {
    name   = "name"
    values = ["debian-13-amd64-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# Server instance: private subnet, no public IP, outbound-only through the NAT GW
resource "aws_instance" "server" {
  ami                         = data.aws_ami.debian.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.wg-poc-server.id]
  associate_public_ip_address = false

  tags = {
    Name = "wg-poc-server"
  }
}