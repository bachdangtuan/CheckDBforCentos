#!/bin/bash

# Moi truong
TOKEN="6112203391:AAEuDTYX3KQRNuoLKuJ0NAtpRoamdHIQQkA"
CHAT_ID="-957135587"
# URL API post telegeram
URL="https://api.telegram.org/bot${TOKEN}/sendMessage"
DB_NAME="jira_20221130";
hostname=$(hostname)
myip=$(hostname -I | awk '{print $1}')
host_ip=$myip
hostname_server=$hostname



export DATE=`date +%Y_%m_%d_%H_%M`
cd /opt/backupJi_conf/


ERROR="
==[BACKUP-ERROR]==
Server: ${hostname_server}
Database: ${DB_NAME}
Address IP : ${host_ip} / 24
Content: Backup backup du lieu khong thanh cong !
--------
Nguyen nhan: Backup DB backup bi ngat giua chung, quyen truy cap sai, hoac khong co db
"

SUCCESS="
==[BACKUP-SUCCESS]==
Server: ${hostname_server}
Database: ${DB_NAME}
Address IP : ${host_ip} / 24
Nguyen nhan: Backup Dump thanh cong databases !
"


alertTelegramSuccess(){
curl -s -X POST $URL \
-G -d chat_id=$CHAT_ID \
--data-urlencode "text=$SUCCESS" \
-d "parse_mode=HTML"
    echo "alert telegram thanh cong"
    exit 0
}

alertTelegramError(){
curl -s -X POST $URL \
-G -d chat_id=$CHAT_ID \
--data-urlencode "text=$ERROR" \
-d "parse_mode=HTML"
    echo "loi sai database"
    exit 0
}



pg_dump $DB_NAME > jira_$DATE.sql
case $? in
  1)
   alertTelegramError
   ;;
  0)
   alertTelegramSuccess
   ;;
  *)
   alertTelegramError
   echo 'No content'
   ;;
esac

