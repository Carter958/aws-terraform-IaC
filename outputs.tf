# outputs.tf in the root directory

output "load_balancer_DNS_name" {
  value = module.compute.load_balancer_dns_name
}


