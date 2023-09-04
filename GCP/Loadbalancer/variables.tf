variable "internet" {
  description = "Internet IP"
	type = string
	default = "0.0.0.0/0"
}

variable "mig-zone" {
	description = "MIG zone"
	type = string
	default = "us-central1-c"
}

variable "region" {
	description = "MIG zone"
	type = string
	default = "us-central1"
}

variable "vpc-subnet-1" {
		description = "MIG zone"
	type = string
	default = "10.0.1.0/24"
}

variable "use-custom-backend" {
	description = "Use custom backend?"
	type = bool
	default = false
}

variable "lb-backend" {
	description = "backend for load balancer"
	type = string
	default = ""
}