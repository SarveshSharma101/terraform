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