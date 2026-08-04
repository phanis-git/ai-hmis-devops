resource "aws_ecr_repository" "backend" {

  name                 = "${var.project_name}/backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  force_delete = true
    tags =  merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}-backend-ecr"
        }
    )
}
resource "aws_ecr_repository" "frontend" {

  name                 = "${var.project_name}/frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  force_delete = true
    tags =  merge(
        local.common_tags,
        {
            Name = "${local.name_prefix}-frontend-ecr"
        }
    )
}