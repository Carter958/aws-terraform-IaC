provider "aws" {
  region = "us-east-1"
}

module "network" {
  source   = "./modules/network"
  vpc_cidr = "10.0.0.0/16"
}

module "compute" {
  source             = "./modules/compute"
  vpc_id             = module.network.vpc_id
  public_subnet_id_1 = module.network.public_subnet_id_1
  public_subnet_id_2 = module.network.public_subnet_id_2
}
