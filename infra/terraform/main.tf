terraform {
  cloud {
    organization = "BootheOdeg"

    workspaces {
      name = "bfwnfwqojfwqonwq"
    }
  }

  provider "aws" {
    region = var.aws_region
  }
}

resource "aws_security_group" "app_sg" {
  name_prefix = "app-sg-"
  description = "Security group for the application server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (restrict in production)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair_name
  security_groups = [aws_security_group.app_sg.name]
  associate_public_ip_address = true

  tags = {
    Name = "gemini-app-server"
  }

  # User data to install Docker and Docker Compose
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io docker-compose git
              sudo usermod -aG docker ubuntu
              newgrp docker
              # Clone the repository and start the application
              # The user will need to replace this with their actual repo URL
              # git clone https://github.com/your-username/DevOps-Stage-6.git /home/ubuntu/DevOps-Stage-6
              # cd /home/ubuntu/DevOps-Stage-6
              # docker compose up -d
              EOF

  provisioner "local-exec" {
    command = "echo '[app_servers]' > ../ansible/inventory.ini && echo '${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/${var.key_pair_name}.pem' >> ../ansible/inventory.ini"
    interpreter = ["bash", "-c"]
  }

  provisioner "local-exec" {
    command     = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../ansible/inventory.ini ../ansible/playbook.yml"
    interpreter = ["bash", "-c"]
    working_dir = ".." # This is important to ensure relative paths in Ansible work correctly
  }
}
