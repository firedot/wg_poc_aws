# Generate random password for the server instance
resource "random_password" "admin" {
  length  = 20
  special = true
}

# Server instance: private subnet, no public IP, outbound-only through the NAT GW
resource "aws_instance" "server" {
  ami                         = data.aws_ami.debian.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private.id
  vpc_security_group_ids      = [aws_security_group.wg-poc-server.id]
  associate_public_ip_address = false
  user_data                   = <<-EOF
    #cloud-config
    chpasswd:
      expire: false
      users:
        - name: admin
          password: ${random_password.admin.bcrypt_hash}
          type: hash
  EOF

  tags = {
    Name = "wg-poc-server"
  }
}