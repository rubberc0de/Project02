output "private_ip" {
  value       = aws_instance.server.private_ip
  description = "Instance private IP"
}

output "instance_id" {
  value       = aws_instance.server.id
  description = "Instance ID for load balancer"
}