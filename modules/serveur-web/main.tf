resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  iam_instance_profile        = var.instance_profile
  associate_public_ip_address = true

  # Performances et Observabilité
  ebs_optimized               = true
  monitoring                  = true

  # Script de démarrage (Installation Nginx, Agent SSM et Configuration SSH)
  user_data = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx amazon-ssm-agent
    systemctl enable nginx amazon-ssm-agent
    systemctl start nginx amazon-ssm-agent
    echo '<h1>AgriCam - Infrastructure IaC Operationnelle</h1>' > /var/www/html/index.html

    # Injection automatique de la clé SSH pour Ansible
    mkdir -p /home/ubuntu/.ssh
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE5SRPUcZ8OhaApaRI/DcFeuustigF+Z6O9Sx1wrFfe1 kamgaludovic13@gmail.com" >> /home/ubuntu/.ssh/authorized_keys
    chown -R ubuntu:ubuntu /home/ubuntu/.ssh
    chmod 700 /home/ubuntu/.ssh
    chmod 600 /home/ubuntu/.ssh/authorized_keys
  EOT

  user_data_replace_on_change = true 

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
    encrypted             = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" 
    http_put_response_hop_limit = 1
  }

  tags = { 
    Name      = "${var.projet}-serveur-${var.environnement}"
    Project   = "AgriCam"
    ManagedBy = "Terraform"
  }
}