# main.tf

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# Terraform Cloud Backend
terraform {
  cloud {
    organization = "BootheOdeg"
    workspaces {
      name = "TODO_Application"
    }
  }
}

# --- EC2 Instance and Security Group ---

resource "aws_security_group" "app_sg" {
  name_prefix = "devops-app-sg-"
  description = "Security group for the DevOps Stage 6 application"
  vpc_id      = var.vpc_id # Assume default VPC if not specified

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: Broad access, restrict in production
    description = "SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: Broad access, restrict in production
    description = "HTTP access for Traefik"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: Broad access, restrict in production
    description = "HTTPS access for Traefik"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "devops-app-sg"
    Project     = "DevOps-Stage-6"
  }
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name    = "devops-app-server"
    Project = "DevOps-Stage-6"
  }
}

# --- Ansible Provisioning ---

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible_inventory.tpl", {
    app_server_ip = aws_instance.app_server.public_ip
    ssh_user      = "ubuntu"
    ssh_key_path  = var.key_pair_name
  })
  filename = "${path.module}/ansible_inventory.ini"
}

resource "null_resource" "ansible_provisioner" {
  depends_on = [aws_instance.app_server]

  # Wait for SSH to be ready before running ansible
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/${var.key_pair_name}.pem")
    host        = aws_instance.app_server.public_ip
  }

  provisioner "local-exec" {
    command = <<-EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${local_file.ansible_inventory.filename} \
      --private-key ~/.ssh/${var.key_pair_name}.pem \
      ../ansible/playbook.yml
    EOT
    working_dir = path.module
  }
}
