#!/bin/bash
function CreateLog() {

  local remail_user=$1

  journalctl -b -p err -p warning -o cat > /tmp/report-$(date +%Y%m%d)
  echo "report from $HOSTNAME" | mail -s report@$HOSTNAME -a /tmp/report-$(date +%Y%m%d) $remail_user
}

function CreateSrvLog() {
  journalctl -u httpd.service -p warning -p err -o cat 
}
