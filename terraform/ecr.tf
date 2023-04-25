resource "aws_ecr_repository" "ecr_repo" {
  name = "comforte-img"
  image_scanning_configuration {
    scan_on_push = true
  }
}
