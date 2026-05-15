output "ip_serveur_public" {
  description = "L'adresse IP publique de notre serveur de production AgriCam"
  value       = module.serveur_web.public_ip
}
