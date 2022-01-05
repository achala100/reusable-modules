variable "ami_id" {
    default = "ami-04505e74c0741db8d"
  
}

variable "instance_type" {
    default = "t2.micro"
}

#variable "public_key" {
    #default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
  
#}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
    type = string

}


variable "public_subnet_01_cidr" {
    default = "10.0.1.0/24"

}

variable "public_subnet_02_cidr" {
    default = "10.0.2.0/24"

}

variable "pravite_subnet_01_cidr" {
    default = "10.0.3.0/24"

}

variable "pravite_subnet_02_cidr" {
    default = "10.0.4.0/24"

}
