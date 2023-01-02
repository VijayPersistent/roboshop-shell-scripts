#!/bin/bash
echo Install Nginx
yum install nginx -y &>>/tmp/frontend
echo Status = $?

echo download the HTDOCS content
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>/tmp/frontend
echo Status = $?

cd /usr/share/nginx/html

echo removing old web content
rm -rf * &>>/tmp/frontend
echo Status = $?

echo extracting web content
unzip /tmp/frontend.zip &>>/tmp/frontend
echo Status = $?

mv frontend-main/static/* . &>>/tmp/frontend
mv frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf &>>/tmp/frontend

echo start the Nginx service
systemctl enable nginx &>>/tmp/frontend
systemctl restart nginx &>>/tmp/frontend
echo Status = $?