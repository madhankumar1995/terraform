resource "aws_ecr_repository" "ecr-repository" {
  count                = length(var.ecr_repositories)
  name                 = var.ecr_repositories[count.index]
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
