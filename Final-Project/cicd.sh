#!/bin/bash
sudo apt update

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    openjdk-17-jdk \
    zip

mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo usermod -G docker ubuntu

sudo chmod 666 /var/run/docker.sock

echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64" | sudo tee -a /home/ubuntu/.bashrc
echo "export PATH=\$PATH:/usr/lib/jvm/java-17-openjdk-amd64/bin" | sudo tee -a /home/ubuntu/.bashrc

source ~/.bashrc
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install -y jenkins

#change ports and make sure port number mathes all three files using sudo
sudo sed -i 's/8080/9090/g' /etc/default/jenkins

sudo sed -i 's/8080/9090/g' /etc/init.d/jenkins

sudo sed -i 's/8080/9090/g' /lib/systemd/system/jenkins.service

sudo systemctl daemon-reload

sudo systemctl restart jenkins

sudo usermod -aG docker jenkins

sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

sudo unzip awscliv2.zip

sudo ./aws/install