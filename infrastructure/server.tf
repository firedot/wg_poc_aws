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

resource "aws_instance" "server" {
  ami           = data.aws_ami.debian.id
  instance_type = "t3.micro"

  tags = {
    Name = "wg-poc-ec2_server"
  }
}