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
  https://github.com/theswordpt-git/Basic-Jenkins-Setup/raw/refs/heads/main/plugins.yaml

sudo -u jenkins java -jar /tmp/jenkins-plugin-manager.jar \
  --war /usr/share/java/jenkins.war \
  --plugin-download-directory /var/lib/jenkins/plugins \
  --plugin-file /tmp/plugins.yaml


# -------------------------------------------
#  Install Snyk in Manage -> Tools automatically
# -------------------------------------------
JENKINS_HOME="/var/lib/jenkins"
CASC_DIR="$JENKINS_HOME/casc_configs"
mkdir -p $CASC_DIR

cat <<EOF > $CASC_DIR/jenkins.yaml
tool:
  snyk:
    installations:
      - name: "snyk"
        properties:
          - installSource:
              installers:
                - snykInstaller:
                    version: "latest"
EOF


#none of these worked, but directly injecting the path into the service file does :(

# 4. Tell Jenkins where to find the configuration
#echo "export CASC_JENKINS_CONFIG=$CASC_DIR/jenkins.yaml" >> /etc/profile
#echo "CASC_JENKINS_CONFIG=$CASC_DIR/jenkins.yaml" >> /etc/environment
#echo "export CASC_JENKINS_CONFIG=$CASC_DIR/jenkins.yaml" > /etc/profile.d/jenkins_env.sh
#chmod +x /etc/profile.d/jenkins_env.sh
#echo 'Environment="CASC_JENKINS_CONFIG=/var/lib/jenkins/casc_configs/jenkins.yaml"' | sudo tee -a /lib/systemd/system/jenkins.service



SERVICE_FILE="/lib/systemd/system/jenkins.service"

# The line to add to the [Service] section
LINE='Environment="CASC_JENKINS_CONFIG=/var/lib/jenkins/casc_configs/jenkins.yaml"'

# Check if the line already exists in the service file
if ! grep -q "$LINE" "$SERVICE_FILE"; then
    # Insert the line after [Service] section if it's not already present
    sed -i '/^\[Service\]/a '"$LINE" "$SERVICE_FILE"
    echo "Line added to $SERVICE_FILE"
else
    echo "Line already exists in $SERVICE_FILE"
fi

# 5. Ensure permissions are correct for the jenkins user
chown -R jenkins:jenkins $JENKINS_HOME


# --------------------------------------
# Start the Jenkins service
# --------------------------------------

# Reload systemd to apply changes
systemctl daemon-reload

#actually start jenkins
systemctl start jenkins
