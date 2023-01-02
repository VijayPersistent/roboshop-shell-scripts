#!/bin/bash
LOG_FILE=/tmp/frontend
echo Install Nginx
yum install nginx -y &>>$LOG_FILE
echo Status = $?

echo download the HTDOCS content
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>$LOG_FILE
echo Status = $?

cd /usr/share/nginx/html

echo removing old web content
rm -rf * &>>$LOG_FILE
echo Status = $?

echo extracting web content
unzip /tmp/frontend.zip &>>$LOG_FILE
echo Status = $?

mv frontend-main/static/* . &>>$LOG_FILE
mv frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE

echo start the Nginx service
systemctl enable nginx &>>$LOG_FILE
systemctl restart nginx &>>$LOG_FILE
echo Status = $?