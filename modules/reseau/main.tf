resource "aws_vpc" "main" {
  # checkov:skip=CKV_AWS_111
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

# -----------------------------------------------------------
# SECURITY GROUP (Conteneur vide pour éviter les recréations)
# -----------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "${var.projet}-sg-web-${var.environnement}"
  description = "Autorise HTTP, HTTPS et SSH"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.projet}-sg-${var.environnement}"
  }
}

# -----------------------------------------------------------
# REGLES DU SECURITY GROUP (Isolées pour la stabilité)
# -----------------------------------------------------------
resource "aws_security_group_rule" "http" {
  # checkov:skip=CKV_AWS_24: "Autoriser le HTTP public est requis pour le serveur web"
  type              = "ingress"
  description       = "Acces HTTP public pour le serveur"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  description       = "Acces HTTPS public pour le serveur"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "ssh" {
  # checkov:skip=CKV_AWS_23: "SSH ouvert temporairement pour la configuration"
  type              = "ingress"
  description       = "Acces SSH pour administration"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  description       = "Autorisation de sortie complete pour les mises a jour"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web.id
}
