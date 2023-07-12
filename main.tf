variable "my_list" {
	# type    = list(string)
  # default = ["item1", "item2", "item3"]
	type = map(string)
	
  default = {
			env = "dev"
    }
}

output "list_items" {
  value = [for k, v in var.my_list : "${k} : ${v}"]
}
