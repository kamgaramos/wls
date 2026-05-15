resource "aws_vpc" "main" {
  # checkov:skip=CKV_AWS_111: "Les Flow Logs seront geres globalement pour application AgriCam"
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.projet}-vpc-${var.environnement}"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_public_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.projet}-subnet-public-${var.environnement}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.projet}-igw-${var.environnement}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.projet}-rt-public-${var.environnement}"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web" {
  # checkov:skip=CKV_AWS_24: "Ouverture du port SSH au public necessaire"
  # checkov:skip=CKV_AWS_260: "Entree du trafic sur les ports 80 et 443 publique pour le serveur"
  # checkov:skip=CKV_AWS_382: "Autorisation SSH publique assumee pour ce deploiement"
  # checkov:skip=CKV_AWS_23: "La regle egress ouverte est requise pour installer Nginx"
  name        = "${var.projet}-sg-web-${var.environnement}"
  description = "Autorise HTTP et SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Acces HTTP public pour le serveur"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Acces HTTPS public pour le serveur"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Acces SSH pour administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Autorisation de sortie complete pour les mises a jour"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.projet}-sg-${var.environnement}"
  }
}
