variable "zone" {
	description = "MIG zone"
	type = string
	default = "us-central1-c"
}

variable "vpc" {
	type = string
	default = "default"
}

variable "subnet" {
	type = string
	default = ""
}

variable "project_name" {
	description = "Name of project"
	type = string
	default = "custom"
}

variable "default_port" {
    description = "Default port"
	type = string
	default = "80"
}

variable "instance" {
  description = "Instances name"
	type = list(string)
	default = []
}

variable "instance_network_ip" {
    description = "Instance network_ip"
	type = list(string)
	default = []
}

variable "neg_name" {
	description = "Name of NEG"
	type = string
	default = ""
}