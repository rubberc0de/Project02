variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "jenkins_size" {
  type = string
}

variable "sonar_size" {
  type = string
}

variable "tomcat_size" {
  type = string
}

variable "sonar_name" {
  type = string
}

variable "jenkins_name" {
  type = string
}

variable "tomcat_name" {
  type = string
}

variable "instance_ami" {
  type = string
}

variable "jenkins_volume" {
  type = number
}

variable "sonar_volume" {
  type = number
}

variable "tomcat_volume" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "internet_rules" {
  type = list(any)
}

variable "ingress_rule_jenkins" {
  type = list(any)
}

variable "egress_rule_jenkins" {
  type = list(any)
}

variable "ingress_rule_sonarqube" {
  type = list(any)
}

variable "egress_rule_sonarqube" {
  type = list(any)
}

variable "SSM_rules" {
  type = list(any)
}

variable "lb_name" {
  type = string
}

variable "nlb_config" {
  type = map(object({
    port        = number
    instance_id = string
  }))
}

variable "lb_health_check" {
  type = string
}

variable "ecr_name" {
  type = string
}

variable "ecr_mutability" {
  type = string
}

variable "ecr_name_app" {
  type = string
}

variable "ecr_mutability_app" {
  type = string
}

variable "backend_bucket" {
  type = string
}

variable "backend_key" {
  type = string
}

variable "backend_region" {
  type = string
}

variable "backend_dynamodb_table" {
  type = string
}

variable "backend_encrypt" {
  type = bool
}

variable "backend_read_capacity" {
  type = number
}

variable "backend_write_capacity" {
  type = number
}