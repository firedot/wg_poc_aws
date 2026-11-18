resource "aws_instance" "relay" {
  ami                         = data.aws_ami.debian.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true

  tags = {
    Name = "wg-poc-relay"
  }
}

resource "aws_instance" "client" {
  ami                         = data.aws_ami.debian.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true

  tags = {
    Name = "wg-poc-client"
  }
}


