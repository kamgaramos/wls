# modules/securite/outputs.tf
output "bucket_stockage_id" { value = aws_s3_bucket.stockage.id }
output "bucket_stockage_arn" { value = aws_s3_bucket.stockage.arn }
output "instance_profile_name" { value = aws_iam_instance_profile.ec2.name }
