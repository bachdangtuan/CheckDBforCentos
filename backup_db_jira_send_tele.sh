#!/bin/bash

# Bien moi truong
TOKEN="6112203391:AAEuDTYX3KQRNuoLKuJ0NAtpRoamdHIQQkA"
CHAT_ID="-957135587"
URL="https://api.telegram.org/bot${TOKEN}/sendMessage"
DBNAME="jira_20221130";
hostname=$(hostname)
myip=$(hostname -I | awk '{print $1}')
host_ip=$myip
hostname_server=$hostname
os_systems=$(grep "PRETTY_NAME" /etc/os-release | awk -F= '{ print $2 }' | tr -d '"')
path_backup='/opt/backupJi_conf/'
export DATE=`date +%Y_%m_%d_%H_%M`



cd $path_backup


ERROR="
==[BACKUP-ERROR]==
Server: ${hostname_server}
Database: ${DBNAME}
Address IP : ${host_ip} / 24
Content: Backup backup du lieu khong thanh cong !
--------
Nguyen nhan: Backup DB backup bi ngat giua chung, quyen truy cap sai, hoac khong co db
"

SUCCESS="
==[BACKUP-SUCCESS]==
Server: ${hostname_server}
Database: ${DBNAME}
Address IP : ${host_ip} / 24
Nguyen nhan: Backup Dump thanh cong databases !
"


alertTelegramSuccess(){
curl -s -X POST $URL \
-G -d chat_id=$CHAT_ID \
--data-urlencode "text=$SUCCESS" \
-d "parse_mode=HTML"
}

alertTelegramError(){
curl -s -X POST $URL \
-G -d chat_id=$CHAT_ID \
--data-urlencode "text=$ERROR" \
-d "parse_mode=HTML"
}


sendSuccessServer(){
capacityFile=$(du -sh jira_$DATE.sql | awk '{print $1}')

curl -X POST http://10.0.0.210:5000/api/databases/info \
-H "Content-Type: application/json" \
-d '{"ipServer": "'"$host_ip"'",
    "hostname": "'"$hostname_server"'",
    "osSystems": "'"$os_systems"'",
    "nameDatabase": "'"$DBNAME"'",
    "pathBackup": "'"$path_backup"'",
    "status": "backup",
    "capacityFile": "'"$capacityFile"'"
    }'
}
sendErrorServer(){
capacityFile=$(du -sh jira_$DATE.sql | awk '{print $1}')

curl -X POST http://10.0.0.210:5000/api/databases/info \
-H "Content-Type: application/json" \
-d '{"ipServer": "'"$host_ip"'",
    "hostname": "'"$hostname_server"'",
    "osSystems": "'"$os_systems"'",
    "nameDatabase": "'"$DBNAME"'",
    "pathBackup": "'"$path_backup"'",
    "status": "error",
    "capacityFile": "'"$capacityFile"'"
    }'
}



pg_dump $DBNAME > $DBNAME_$DATE.sql
case $? in
  1)
   alertTelegramError
   sendErrorServer
   exit 0
   ;;
  0)
   alertTelegramSuccess
   sendSuccessServer
   exit 0
   ;;
  *)
   alertTelegramError
   echo 'No content'
   ;;
esac

