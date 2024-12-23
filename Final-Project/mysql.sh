#!/bin/bash

sudo apt update

sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git

mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

sudo usermod -G docker ubuntu

sudo chmod 666 /var/run/docker.sock

cd /home/ubuntu
git clone https://github.com/daphnen7777/dbmaster.git

cd /home/ubuntu/dbmaster/mysql/

docker build -t masterdb:1.0 .

docker run -d --name masterdb -p 3306:3306 --restart always masterdb:1.0

sudo docker exec -it masterdb sh -c "mysqldump -u root -proot pratice_board > dump.sql"

sudo docker cp masterdb:dump.sql .

sudo docker exec -it masterdb sh -c "mysql -u root -proot -e 'SHOW MASTER STATUS\G' > master.txt"

sudo docker cp masterdb:master.txt .