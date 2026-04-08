terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-2"  # change as needed
}

# Security group for SSH
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Latest Amazon Linux 2023 AMI
# 1. Fetch the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    # Added "2023.*" to ensure we don't accidentally pick up minimal/specialty images
    values = ["al2023-ami-2023.*-x86_64"] 
  }

  filter {
    name   = "architecture"
    values = ["x86_64"] # Matches t3 instance family
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"] # Required for t3 instances
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"] # Required for t3 instances
  }
}


# EC2 Instance
resource "aws_instance" "jenkins_ec2" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  

  
  instance_type = "t3.medium"
  key_name                    = "YourEC2KeyGoesHere"  # your existing key
  security_groups             = [aws_security_group.jenkins_sg.name]
  associate_public_ip_address = true
  

  user_data = file("${path.module}/user-data.sh")
  
 
 
 # Specify a larger root volume
  root_block_device {
    volume_size           = 100   # size in GB
    volume_type           = "gp3"  # fast general-purpose SSD
    delete_on_termination = true   # optional, deletes when instance is terminated
  }
 
 #dump the init password on screen
provisioner "remote-exec" {
    inline = [
      # Wait for Jenkins to be fully started by checking its service status in a loop
      "until systemctl is-active --quiet jenkins; do echo 'Waiting for Jenkins to start...'; sleep 10; done",
      "echo Default Password:",
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
    ]

    # Connection block to SSH into the instance
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("YourEC2KeyGoesHere.pem")  # Path to your private SSH key
      host        = self.public_ip
    }
  }


  tags = {
    Name = "jenkins-server"
  }
}


# Output the Public DNS of the EC2 instance
output "ec2_public_dns" {
  value = aws_instance.jenkins_ec2.public_dns
}


# Output the Jenkins URL
output "jenkins_url" {
  value = lower("http://${aws_instance.jenkins_ec2.public_dns}:8080")
}




