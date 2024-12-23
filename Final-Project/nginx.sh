#!/usr/bin/env bash

# 시스템 업데이트 및 Docker 설치
sudo yum update -y
sudo amazon-linux-extras install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# 의존성 설치
sudo amazon-linux-extras install -y epel && sudo yum install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  git \

sudo chmod 666 /var/run/docker.sock # Docker 소켓 권한 설정

# GitHub 코드 클론
cd /home/ec2-user
git clone https://github.com/daphnen7777/post.git

cd /home/ec2-user/post/nginxweb

# Docker 이미지 빌드
docker build -t nginxweb:1.0 .

# ECR 컨테이너 실행
docker run --name nginxweb -p 80:80 -d --restart always nginxweb:1.0
