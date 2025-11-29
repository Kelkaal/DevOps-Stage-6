# main.tf

provider "aws" {
  region = var.aws_region
}

terraform {
  cloud {
    organization = "BootheOdeg"
    workspaces {
      name = "TODO_Application"
    }
  }
}

resource "aws_security_group" "app_sg" {
  name_prefix = "devops-app-sg-"
  description = "Security group for the DevOps Stage 6 application"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "devops-app-sg"
    Project = "DevOps-Stage-6"
  }
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  root_block_device {
    volume_size = 20 # Increased disk size
  }

  tags = {
    Name    = "devops-app-server"
    Project = "DevOps-Stage-6"
  }
}

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

  provisioner "local-exec" {
    command = <<EOT
      # Wait 30 seconds for the instance to fully boot and start sshd
      echo "Waiting for instance to boot..."
      sleep 30

      # Wait for SSH to be ready by polling the port
      until nc -zw5 ${aws_instance.app_server.public_ip} 22; do
          echo "Waiting for SSH port to open..."
          sleep 5
      done
      echo "SSH port is open! Starting Ansible."

      # Now run Ansible
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${local_file.ansible_inventory.filename} \
      --private-key ~/.ssh/${var.key_pair_name}.pem \
      ../ansible/playbook.yml
    EOT
    working_dir = path.module
  }
}
