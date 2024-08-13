# outputs.tf in the root directory

output "test_output" {
  value = module.compute.load_balancer_dns_name
}


