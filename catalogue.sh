LOG_FILE=/tmp/catalogue
echo "setup nodejs repos"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

echo "install nodejs"
yum install nodejs -y &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

echo "add application roboshop user"
useradd roboshop &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

echo "download catalogue application code"
curl -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

cd /home/roboshop

echo "extract catalogue application code"
unzip /tmp/catalogue.zip &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

mv catalogue-main catalogue
cd /home/roboshop/catalogue

echo "install nodejs dependencies"
npm install &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

echo "setup catalogue service"
mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi

systemctl daemon-reload &>>${LOG_FILE}
systemctl enable catalogue &>>${LOG_FILE}

echo "start catalogue service"
systemctl start catalogue &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  echo Status = SUCCESS
else
  echo Status = FAILURE
  exit 1
fi
