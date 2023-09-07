variable "project_id" {
	type = string
	default = ""
}

variable "region" {
	type = string
	default = ""
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