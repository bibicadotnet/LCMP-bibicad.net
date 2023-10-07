#!/bin/bash
#setup releem
mysql 2>/dev/null <<EOF
CREATE USER 'releem'@'%' identified by '[Password]';
GRANT PROCESS, REPLICATION CLIENT, SHOW VIEW ON *.* TO 'releem'@'%';
GRANT SELECT ON performance_schema.events_statements_summary_by_digest TO 'releem'@'%';
FLUSH PRIVILEGES;
EXIT;
EOF
yes y| RELEEM_MYSQL_PASSWORD='[Password]' RELEEM_MYSQL_LOGIN='releem' RELEEM_MYSQL_MEMORY_LIMIT=0 RELEEM_API_KEY=c734e3de-3b21-4c29-96c4-26f3cdaf902f RELEEM_CRON_ENABLE=1 bash -c "$(curl -L https://releem.s3.amazonaws.com/v2/install.sh)"

# setup crontab cho releem (Recommended Configuration)
crontab -l > releem
echo "0 3 * * * yes y| /bin/bash /opt/releem/mysqlconfigurer.sh -a" >> releem
crontab releem
