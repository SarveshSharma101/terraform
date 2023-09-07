variable "pub_subnet_count" {
  description = "Number of subnets to create"
  type        = number
  default     = 2 # You can set your desired default count
}

variable "private_subnet_count" {
  description = "Number of subnets to create"
  type        = number
  default     = 2 # You can set your desired default count
}

variable "project_name" {
	description = "Name of project"
	type = string
	default = "custom"
}

variable "public_region" {
	description = "Public subnet region"
	type = string
	default = ""
}

variable "private_region" {
	description = "private subnet region"
	type = string
	default = ""
}

variable "internet" {
 	description = "Internet IP"
	type = string
	default = "0.0.0.0/0"
}