#!/bin/bash

USER=""

DNS_HOST=""
WEB_HOST=""
DB_HOST=""
SHELL_FTP_HOST=""

BASE="/backups"

mkdir -p "$BASE/dns" "$BASE/web" "$BASE/database" "$BASE/shell-ftp"

echo "[+] DNS server"
rsync -a \
  $USER@$DNS_HOST:/etc/ssh/sshd_config \
  $USER@$DNS_HOST:/etc/named.conf \
  $USER@$DNS_HOST:/etc/named \
  $USER@$DNS_HOST:/etc/passwd \
  $USER@$DNS_HOST:/etc/shadow \
  $BASE/dns/

echo "[+] Web server"
rsync -a \
  $USER@$WEB_HOST:/etc/ssh/sshd_config \
  $USER@$WEB_HOST:/etc/httpd \
  $USER@$WEB_HOST:/etc/nginx \
  $USER@$WEB_HOST:/var/lib/etechacademy \
  $USER@$WEB_HOST:/etc/passwd \
  $USER@$WEB_HOST:/etc/shadow \
  $BASE/web/

echo "[+] Database server"
ssh $USER@$DB_HOST "sudo pg_dumpall -U postgres > /tmp/pgdump_all.sql"
rsync -a \
  $USER@$DB_HOST:/tmp/pgdump_all.sql \
  $USER@$DB_HOST:/etc/ssh/sshd_config \
  $USER@$DB_HOST:/etc/postgresql \
  $USER@$DB_HOST:/etc/passwd \
  $USER@$DB_HOST:/etc/shadow \
  $BASE/database/

echo "[+] Shell / FTP server"
rsync -a \
  $USER@$SHELL_FTP_HOST:/etc/ssh/sshd_config \
  $USER@$SHELL_FTP_HOST:/etc/vsftpd.conf \
  $USER@$SHELL_FTP_HOST:/etc/vsftpd \
  $USER@$SHELL_FTP_HOST:/etc/passwd \
  $USER@$SHELL_FTP_HOST:/etc/shadow \
  $BASE/shell-ftp/

echo "[+] All backups complete."
