# outputs.tf in /modules/compute

output "autoscaling_group_id" {
  value = aws_autoscaling_group.app.id
}

# Output the DNS name of the Load Balancer
output "load_balancer_dns_name" {
  value       = aws_lb.app.dns_name
  description = "The DNS name of the load balancer"
}
