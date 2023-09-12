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

# module "mig" {
# 	source = "./modules/MIG"
# 	vpc = module.vpc.vpc.vpc.name
# 	subnet = module.vpc.vpc.private-subnet[0].id
# 	zone = "asia-south1-a"
# }

module "loadbalancer" {
	depends_on = [ module.NEG ]
	source = "./modules/Loadbalancer"
	lb-backend  = module.NEG.op.neg.id
}

resource "google_compute_instance" "endpoint-instance-1" {
	name = "endpoint-instance-1"
	machine_type = "e2-micro"
	zone = "asia-south1-a"

	network_interface {
		network = module.vpc.vpc.vpc.name
		subnetwork = module.vpc.vpc.private-subnet[0].id
		
	}

	tags = ["endpoint-instance"]
	labels = {
	"owner" = "terraform"
	"env" = "endpoint-instance"
	"instance" = "1"
	}
	boot_disk {
		initialize_params {
			image = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
			size = 30
			type = "pd-balanced"
			labels = {
				"instace" : "1"
			}
		}
	}
}


resource "google_compute_instance" "endpoint-instance-2" {
	name = "endpoint-instance-2"
	machine_type = "e2-micro"
	zone = "asia-south1-a"

	network_interface {
		network = module.vpc.vpc.vpc.name
		subnetwork = module.vpc.vpc.private-subnet[0].id
		
	}

	tags = ["endpoint-instance"]
	labels = {
	"owner" = "terraform"
	"env" = "endpoint-instance"
	"instance" = "1"
	}
	boot_disk {
		initialize_params {
			image = "ubuntu-os-cloud/ubuntu-minimal-2204-lts"
			size = 30
			type = "pd-balanced"
			labels = {
				"instace" : "1"
			}
		}
	}
}



module "NEG" {
	source = "./modules/NEG"
	project_name = "test"
	vpc = module.vpc.vpc.vpc.name
	subnet = module.vpc.vpc.private-subnet[0].id
	default_port = "80"
	zone = "asia-south1-a"
}

module "NE" {
	source = "./modules/NE"
	project_name = "test"
	neg_name = module.NEG.op.neg.name
	zone = "asia-south1-a"
	instance = [google_compute_instance.endpoint-instance-1.name, google_compute_instance.endpoint-instance-2.name]
	default_port = "80"
	instance_network_ip = [google_compute_instance.endpoint-instance-1.network_interface[0].network_ip, google_compute_instance.endpoint-instance-2.network_interface[0].network_ip]

}