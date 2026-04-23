resource "aws_instance" "server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids

  iam_instance_profile = var.iam_instance_profile

  tags = merge(
    var.common_tags,
    {
      Name = var.instance_name
    }
  )
}