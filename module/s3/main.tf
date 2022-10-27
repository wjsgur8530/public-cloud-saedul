# saedul/module/s3/main.tf

resource "aws_s3_bucket" "cookalone-s3" {
  bucket = "${var.env}-s3-bucket"
}

resource "aws_s3_bucket_acl" "cookalone-s3_acl" {
  bucket = aws_s3_bucket.cookalone-s3.id
  acl    = "private"
}
resource "aws_s3_bucket_lifecycle_configuration" "cookalone-s3-lifecycle" {
  bucket = aws_s3_bucket.cookalone-s3.id

  rule {
    id = "img"

    expiration {
      days = 180
    }

    filter {
      prefix = "image/"
    }

    status = "Enabled"
  }
} 

resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = aws_s3_bucket.cookalone-s3.id
  versioning_configuration {
    status = "Disabled"
  }
}


data "aws_iam_policy_document" "allow_access_from_endpoint_doc" {
  statement {
    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    sid = "allow access from endpoint"

    actions = ["s3:*"]

    resources = [
      "arn:aws:s3:::${var.env}-s3-bucket",
      "arn:aws:s3:::${var.env}-s3-bucket/*"
    ]

    condition {
      test = "StringEquals"

      variable = "aws:SourceVpce"

      values = [
        var.endpoint
      ]
    }
  }
}
resource "aws_s3_bucket_policy" "allow_access_from_endpoint" {
  bucket = aws_s3_bucket.cookalone-s3.id
  policy = data.aws_iam_policy_document.allow_access_from_endpoint_doc.json
}

