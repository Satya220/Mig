#!/bin/bash
sudo yum check-update
sudo yum update
sudo yum -y install httpd
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl status httpd 
echo "Hello" > /var/www/html/index.html