resource "aws_ecr_repository" "container_registry" {
    name = var.name
    image_tag_mutability = var.mutability

}