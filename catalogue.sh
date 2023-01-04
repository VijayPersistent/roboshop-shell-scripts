LOG_FILE=/tmp/catalogue

ID=$(id -u)
if [ $ID -ne 0 ]; then
  echo You should run this script as root user or with sudo privileges
  exit 1
fi

StatusCheck(){
  if [ $1 -eq 0 ]; then
    echo Status = SUCCESS
  else
    echo Status = FAILURE
    exit 1
  fi
}
echo "setup nodejs repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG_FILE}
StatusCheck $?

echo "install nodejs"
yum install nodejs -y &>>${LOG_FILE}
StatusCheck $?

id roboshop &>>${LOG_FILE}
if [ $? -ne 0 ]; then
echo "add roboshop application  user"
useradd roboshop &>>${LOG_FILE}
   StatusCheck $?
fi

echo "download catalogue application code"
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>${LOG_FILE}
StatusCheck $?

cd /home/roboshop

echo "clean old app content"
rm -rf catalogue &>>${LOG_FILE}
StatusCheck $?

echo "extract catalogue application code"
unzip /tmp/catalogue.zip &>>${LOG_FILE}
StatusCheck $?

mv catalogue-main catalogue
cd /home/roboshop/catalogue

echo "install nodejs dependencies"
npm install &>>${LOG_FILE}
StatusCheck $?

echo "setup catalogue service"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>${LOG_FILE}
StatusCheck $?

systemctl daemon-reload &>>${LOG_FILE}
systemctl enable catalogue &>>${LOG_FILE}

echo "start catalogue service"
systemctl start catalogue &>>${LOG_FILE}
StatusCheck $?
