module "reseau" {
  source             = "../../modules/reseau"
  vpc_cidr           = var.vpc_cidr
  subnet_public_cidr = var.subnet_public_cidr
  projet             = var.projet
  environnement      = var.environnement
}

module "iam" {
  source        = "../../modules/securite"
  projet        = var.projet
  environnement = var.environnement
  suffix        = var.suffix
}

module "serveur_web" {
  source            = "../../modules/serveur-web"
  projet            = var.projet
  environnement     = var.environnement
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = module.reseau.subnet_id
  security_group_id = module.reseau.security_group_id
  instance_profile  = module.iam.instance_profile_name
}
