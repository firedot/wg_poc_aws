output "server_ami_name" {
  description = "ami name which the server is based on"
  value       = data.aws_ami.debian.name
}

output "server_ami_id" {
  description = "ami id which the server is based on"
  value       = data.aws_ami.debian.id
}