variable "aws_region" { type = string }
variable "environnement" { type = string }
variable "projet" { type = string }
variable "vpc_cidr" { type = string }
variable "subnet_public_cidr" { type = string }
variable "instance_type" { type = string }
variable "ami_id" { type = string }

# variable "db_password" {
#   type      = string
#   sensitive = true
# }

variable "suffix" {
  type = string
}

# variable "retention_jours" {
#   type    = number
#   default = 7
# }

# variable "enable_log_file_validation" {
#   type    = bool
#   default = true
# }