# outputs.tf in the root directory

output "vpc_id" {
  value = module.network.vpc_id
}

output "test_output" {
  value = module.compute.load_balancer_dns_name
}


