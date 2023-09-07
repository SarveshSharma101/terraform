terraform {
	required_providers {
		google = {
			source = "hashicorp/google"
    version = "4.51.0"
		}
	}
}

provider "google" {
	credentials = file("/mnt/c/Users/ppain/Desktop/mws/t-key/terraform-practice-392512-379f604ce6fb.json")

	project = "terraform-practice-392512"
}

module "vpc" {
	source = "./modules/VPC"
	project_name = "test"
	pub_subnet_count = 2
	private_subnet_count = 2
	public_region = "us-central1"
	private_region = "asia-south1"
}

module "cloud-nat" {
	depends_on = [ module.vpc ]
	source = "./modules/Cloud-Nat"
	project_name = "test"
	region = module.vpc.vpc.private-subnet[0].region	
	vpc = module.vpc.vpc.vpc.name
}

module "mig" {
	source = "./modules/MIG"
	vpc = module.vpc.vpc.vpc.name
	subnet = module.vpc.vpc.private-subnet[0].id
	zone = "asia-south1-a"
}

module "loadbalancer" {
	depends_on = [ module.mig ]
	source = "./modules/Loadbalancer"
	lb-backend  = module.mig.mig.mig.instance_group
}