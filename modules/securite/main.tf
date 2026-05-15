# ── Bucket S3 AgriCam avec chiffrement ─────────────────────────────
resource "aws_s3_bucket" "stockage" {
  bucket        = "${var.projet}-stockage-${var.environnement}-${var.suffix}"
  force_destroy = true
  tags          = { Name = "${var.projet}-stockage-${var.environnement}" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "stockage" {
  bucket = aws_s3_bucket.stockage.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "stockage" {
  bucket = aws_s3_bucket.stockage.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_public_access_block" "stockage" {
  bucket                  = aws_s3_bucket.stockage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "stockage_lifecycle" {
  bucket = aws_s3_bucket.stockage.id
  rule {
    id     = "cleanup"
    status = "Enabled"

    filter {
      prefix = ""
    }

    expiration { days = 90 }
  }
}

resource "aws_s3_bucket_logging" "stockage_logging" {
  bucket        = aws_s3_bucket.stockage.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/"
}

# ── Bucket S3 pour les logs CloudTrail ──────────────────────────────
resource "aws_s3_bucket" "logs" {
  bucket        = "${var.projet}-cloudtrail-logs-${var.environnement}-${var.suffix}"
  force_destroy = true
  tags          = { Name = "${var.projet}-cloudtrail-logs-${var.environnement}", Type = "Logs" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "logs_lifecycle" {
  bucket = aws_s3_bucket.logs.id
  rule {
    id     = "archive"
    status = "Enabled"

    filter {
      prefix = ""
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
    expiration { days = 365 }
  }
}

# ── Identité AWS et Politiques S3 CloudTrail ───────────────────────
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.logs.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# ── Configuration de la sécurité IAM pour l'EC2 ───────────────────
resource "aws_iam_role" "ec2" {
  name = "${var.projet}-role-ec2-${var.environnement}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.projet}-profile-ec2-${var.environnement}"
  role = aws_iam_role.ec2.name
}
