output "public_ip" {
  description = "L'adresse IP publique de l'instance web AgriCam"
  value       = aws_instance.web.public_ip
}

output "instance_id" {
  description = "L'ID de l'instance EC2 pour le monitoring"
  value       = aws_instance.web.id
}

output "instance_arn" {
  description = "L'ARN de l'instance pour les politiques IAM"
  value       = aws_instance.web.arn
}