
resource "aws_s3_bucket" "dohp-s3bucket" {
  bucket_prefix = var.s3_bucket_prefix

  tags = {
    environment = var.environment
    managedby   = "terraform"
  }
}

resource "aws_s3_bucket_acl" "dohp-s3bucket-acl" {
  bucket = aws_s3_bucket.dohp-s3bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "dohp-s3bucket-versioning" {
  bucket = aws_s3_bucket.dohp-s3bucket.id
  versioning_configuration {
    status = var.s3_versioning
  }
}
