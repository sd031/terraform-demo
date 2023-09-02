terraform {
 backend "s3" {
    bucket = "terraform-demo-sandip-sd031"
    key    = "demo"
    region = "us-west-2"
  }
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}


module "vpc" {
  source    = "./modules/vpc"
}

module "compute" {
  source    = "./modules/compute"
  aws_region = var.aws_region
  aws_amis =  var.aws_amis
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_id
  instance_type = var.instance_type
}


module "elb" {
  source    = "./modules/elb"
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.subnet_id
  instance_id = module.compute.instance_id
}








