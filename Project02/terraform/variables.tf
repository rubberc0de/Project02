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

variable "sonar_name" {
  type = string
}

variable "jenkins_name" {
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

variable "ingress_rule_prometheus" {
  type = list(any)
}

variable "ingress_rule_grafana" {
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

variable "prometheus_size" {
  type = string
}

variable "prometheus_name" {
  type = string
}

variable "prometheus_volume" {
  type = string
}
