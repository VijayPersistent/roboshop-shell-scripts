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

NODEJS(){
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

  echo "download ${COMPONENT} application code"
  curl -s -L -o /tmp/user.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG_FILE}
  StatusCheck $?

  cd /home/roboshop

  echo "clean old app content"
  rm -rf ${COMPONENT} &>>${LOG_FILE}
  StatusCheck $?

  echo "extract $(COMPONENT) application code"
  unzip /tmp/${COMPONENT}.zip &>>${LOG_FILE}
  StatusCheck $?

  mv user-main ${COMPONENT}
  cd /home/roboshop/${COMPONENT}

  echo "install nodejs dependencies"
  npm install &>>${LOG_FILE}
  StatusCheck $?

echo "Update Systemd service file"
sed -i -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service
StatusCheck $?

echo "setup ${COMPONENT} service"
mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG_FILE}
StatusCheck $?

systemctl daemon-reload &>>${LOG_FILE}
systemctl enable ${COMPONENT} &>>${LOG_FILE}

echo "start $(COMPONENT) service"
systemctl start ${COMPONENT} &>>${LOG_FILE}
StatusCheck $?
}