resource "aws_s3_bucket" "s3" {
  bucket = "terraform-bucket"
  acl    = "private"

  tags = {
    Environment = "production"
  }
}
