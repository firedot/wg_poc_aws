# creating SSH key pairs

resource "aws_key_pair" "wg-poc" {
    key_name = "wg-poc"
    public_key = file(pathexpand("~/.ssh/aws_wg_poc_acc.pub"))
}

# WireGuard hub acting as relay for server
resource "aws_instance" "relay" {
  ami                         = data.aws_ami.debian.id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.wg-poc-relay.id]
  associate_public_ip_address = true
  

  tags = {
    Name = "wg-poc-relay"
  }
}

# Client machine used for testing the PoC
resource "aws_instance" "client" {
  ami                         = data.aws_ami.debian.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true

  tags = {
    Name = "wg-poc-client"
  }
}


