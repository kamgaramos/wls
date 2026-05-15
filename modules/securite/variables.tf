variable "projet" {
  type = string
}

variable "environnement" {
  type = string
}

variable "suffix" {
  type    = string
  default = "kc1-agricam-final-2026" # <-- Sécurise le déploiement si la variable arrive vide
}

variable "retention_jours" {
  type    = number
  default = 7
}

variable "enable_log_file_validation" {
  type    = bool
  default = true
}

variable "kms_key_id" {
  type    = string
  default = null
}
