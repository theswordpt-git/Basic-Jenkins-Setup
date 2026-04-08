#!/bin/bash

# --------------------------------------
# Update all installed packages
# --------------------------------------
 yum update -y

# --------------------------------------
# Add the Jenkins repository to yum sources
# --------------------------------------
 wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

# --------------------------------------
# Import the Jenkins GPG key to verify packages
# --------------------------------------
 rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# --------------------------------------
# Upgrade all packages (including those from the new Jenkins repo)
# --------------------------------------
 yum upgrade -y

# --------------------------------------
# Install Amazon Corretto 21 (required Java version for Jenkins)
# --------------------------------------
 yum install java-21-amazon-corretto -y

# --------------------------------------
# Install Jenkins
# --------------------------------------
 yum install jenkins -y

# --------------------------------------
# Enable Jenkins to start at boot
# --------------------------------------
 systemctl enable jenkins


# --------------------------------------
# Make space on the server in the /tmp folder
# --------------------------------------

 mount -o remount,size=8G /tmp


#---------------------------------------
# Install Git abd other stuff
#---------------------------------------
 yum install git -y

#JG: install terraform and tmux too (amazon 2023 ami)
 dnf install -y dnf-plugins-core
 dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
 dnf -y install terraform tmux



# --------------------------------------
#  Install plugins
# --------------------------------------

curl -fLs -o /tmp/jenkins-plugin-manager.jar \
  https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/2.14.0/jenkins-plugin-manager-2.14.0.jar

curl -fLs -o /tmp/plugins.yaml \
  https://github.com/theswordpt-git/Jenkins-Test-Git/raw/refs/heads/main/Jenkins-Server-Terraform/plugins.yaml

 -u jenkins java -jar /tmp/jenkins-plugin-manager.jar \
  --war /usr/share/java/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins \
  --plugin-file /tmp/plugins.yaml



# --------------------------------------
# Start the Jenkins service
# --------------------------------------

 systemctl start jenkins
 
 
 
 
