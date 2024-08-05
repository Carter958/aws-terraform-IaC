# outputs.tf in /modules/compute

output "autoscaling_group_id" {
  value = aws_autoscaling_group.app.id
}