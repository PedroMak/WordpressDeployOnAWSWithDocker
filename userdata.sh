#!/bin/bash

sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo yum install nfs-utils amazon-efs-utils -y
sudo mkdir -p /mnt/efs/wordpress
sudo chmod +rwx /mnt/efs/wordpress
echo "<efsID>:/ /mnt/efs efs _netdev,tls 0 0" | sudo tee -a /etc/fstab
sudo mount -a

mkdir -p /home/ec2-user/wordpress
cat <<EOF > /home/ec2-user/wordpress/docker-compose.yml
services:
  wordpress:
    image: wordpress
    volumes:
      - /mnt/efs/wordpress:/var/www/html
    restart: always
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: <database endpoint>
      WORDPRESS_DB_USER: <master user>
      WORDPRESS_DB_PASSWORD: <master password>
      WORDPRESS_DB_NAME: <initial database name>
EOF

cd /home/ec2-user/wordpress
sudo /usr/local/bin/docker-compose up -d