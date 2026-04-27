module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "VPC"
  cidr = "10.0.0.0/16"

  azs             = ["eu-south-2a", "eu-south-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Private     = "true"
    Environment = "dev"
  }
}

module "iam_ssm" {
  source       = "./modules/iam"
  project_name = var.project_name
}

#Security groups

module "jenkins_security" {
  source         = "./modules/security"
  sg_description = "Jenkins port 8080"
  vpc_id         = module.vpc.vpc_id
  sg_name        = "jenkins-sg"
  ingress_rules  = var.ingress_rule_jenkins
  egress_rules   = var.egress_rule_jenkins
}

module "ssm_security" {
  source         = "./modules/security"
  sg_description = "Allow connectivity to SSM endpoints"
  vpc_id         = module.vpc.vpc_id
  sg_name        = "SSM-sg"
  ingress_rules   = var.SSM_rules
  egress_rules  = var.SSM_rules
}

module "internet_security" {
  source         = "./modules/security"
  sg_description = "Allow connectivity to the Internet on port 80 & 443"
  vpc_id         = module.vpc.vpc_id
  sg_name        = "Internet-sg"
  ingress_rules   = var.internet_rules
  egress_rules  = var.internet_rules
}

module "sonar_security" {
  source         = "./modules/security"
  sg_description = "Sonarqube port 9000"
  vpc_id         = module.vpc.vpc_id
  sg_name        = "sonar-sg"
  ingress_rules  = var.ingress_rule_sonarqube
  egress_rules   = var.egress_rule_sonarqube
}

#Instances

module "Jenkins" {
  source               = "./modules/compute"
  instance_name        = var.jenkins_name
  iam_instance_profile = module.iam_ssm.instance_profile_name
  subnet_id            = module.vpc.private_subnets[0]
  vpc_security_group_ids = [
    module.jenkins_security.sg_id,
    module.internet_security.sg_id,
    module.ssm_security.sg_id
  ]

  ami_id        = var.instance_ami
  instance_type = var.jenkins_size
  volume_size   = var.jenkins_volume

  common_tags = var.common_tags

}

module "Sonar" {
  source               = "./modules/compute"
  instance_name        = var.sonar_name
  iam_instance_profile = module.iam_ssm.instance_profile_name
  subnet_id            = module.vpc.private_subnets[0]
  vpc_security_group_ids = [
    module.sonar_security.sg_id,
    module.internet_security.sg_id,
    module.ssm_security.sg_id
  ]

  ami_id        = var.instance_ami
  instance_type = var.sonar_size
  volume_size   = var.sonar_volume

  common_tags = var.common_tags

}

module "Tomcat" {
  source               = "./modules/compute"
  instance_name        = var.tomcat_name
  iam_instance_profile = module.iam_ssm.instance_profile_name
  subnet_id            = module.vpc.private_subnets[0]
  vpc_security_group_ids = [
    module.jenkins_security.sg_id,
    module.internet_security.sg_id,
    module.ssm_security.sg_id
  ]

  ami_id        = var.instance_ami
  instance_type = var.tomcat_size
  volume_size   = var.tomcat_volume

  common_tags = var.common_tags

}

#Connection to SSM



resource "aws_vpc_endpoint" "ssm_endpoints" {
  for_each = toset(["ssm", "ssmmessages", "ec2messages"])

  vpc_id            = module.vpc.vpc_id
  vpc_endpoint_type = "Interface"

  service_name = "com.amazonaws.${var.aws_region}.${each.value}"

  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [module.ssm_security.sg_id]
  private_dns_enabled = true
}

#Loadbalancing

resource "aws_lb" "main" {
  name               = "main-nlb"
  load_balancer_type = "network"
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "listener" {
  for_each          = aws_lb_target_group.tg
  load_balancer_arn = aws_lb.main.arn
  port              = each.value.port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = each.value.arn
  }
}

resource "aws_lb_target_group" "tg" {
  for_each = var.nlb_config
  name     = "${each.key}-tg"
  port     = each.value.port
  protocol = "TCP"
  vpc_id   = module.vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = aws_lb_target_group.tg["jenkins"].arn
  target_id        = module.Jenkins.instance_id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "attach_sonar" {
  target_group_arn = aws_lb_target_group.tg["sonar"].arn
  target_id        = module.Sonar.instance_id
  port             = 9000
}