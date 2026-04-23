variable "instance_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "ami_id" {
  type = string
}
variable "subnet_id" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "iam_instance_profile" {
  type = string
}

variable "volume_size" {
  type = number
}

variable "common_tags" {
  type = map(string)
}

variable "public_ip" {
  type = number
  default = 0
}