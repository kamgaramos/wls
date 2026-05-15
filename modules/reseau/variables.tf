variable "vpc_cidr" {
  description = "CIDR du VPC"
  type        = string
}

variable "subnet_public_cidr" {
  description = "CIDR du subnet public"
  type        = string
}

variable "projet" {
  description = "Nom du projet"
  type        = string
}

variable "environnement" {
  description = "Environnement (dev/prod)"
  type        = string
}
