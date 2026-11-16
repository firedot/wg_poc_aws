output "server_ami_name" {
  description = "ami name which the server is based on"
  value       = data.aws_ami.debian.name
}

output "server_ami_id" {
  description = "ami id which the server is based on"
  value       = data.aws_ami.debian.id
}

output "server_admin_password" {
    description= "Password of the admin (serial console login)"
    value = random_password.admin.result
    sensitive = true
}