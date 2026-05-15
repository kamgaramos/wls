variable "projet" {
  description = "Nom du projet"
  type        = string
}

variable "environnement" {
  description = "Environnement (prod/dev)"
  type        = string
}

variable "ami_id" {
  description = "ID de l'AMI AWS"
  type        = string
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
}

variable "subnet_id" {
  description = "ID du subnet"
  type        = string
}

variable "security_group_id" {
  description = "ID du security group"
  type        = string
}

variable "instance_profile" {
  description = "Nom du profil IAM"
  type        = string
}