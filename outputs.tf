# outputs.tf in the root directory

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_ip" {
  value = module.compute.public_ip
}
