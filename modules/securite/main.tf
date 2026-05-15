# ── Bucket S3 AgriCam avec chiffrement ─────────────────────────────
resource "aws_s3_bucket" "stockage" {
  bucket        = "${var.projet}-stockage-${var.environnement}-${var.suffix}"
  force_destroy = true # <--- Ajouté pour permettre la mise à jour sans blocage
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

# Correction CKV2_AWS_61 : Gestion du cycle de vie avec filtre explicite
resource "aws_s3_bucket_lifecycle_configuration" "stockage_lifecycle" {
  bucket = aws_s3_bucket.stockage.id
  rule {
    id     = "cleanup"
    status = "Enabled"

    # Ajout du filtre pour supprimer le Warning
    filter {
      prefix = ""
    }

    expiration { days = 90 }
  }
}

# Correction CKV_AWS_18 : Activation du logging des accès
resource "aws_s3_bucket_logging" "stockage_logging" {
  bucket        = aws_s3_bucket.stockage.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/"
}

# ── Bucket S3 pour les logs CloudTrail ──────────────────────────────
resource "aws_s3_bucket" "logs" {
  bucket        = "${var.projet}-cloudtrail-logs-${var.environnement}-${var.suffix}"
  force_destroy = true # <--- Ajouté pour corriger l'erreur BucketNotEmpty
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

# Correction CKV2_AWS_61 : Gestion du cycle de vie pour les logs avec filtre
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

# Politique S3 requise par CloudTrail pour ecrire les logs
data "aws_caller_identity" "current
