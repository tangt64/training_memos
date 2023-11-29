#!/bin/bash

firewall-cmd --get-zones | sed -E -e 's/[[:blank:]]+/\n/g' > zones.list

while read zones
do
  firewall-cmd --list-all --zone=$zones | grep 'rule family="ipv4"' | sed -e 's/^[ \t]*//' > richrule.list
  while read richrule
  do
  firewall-cmd --permanent --zone=$zones --remove-rich-rule "$richrule"
  done < richrule.list

  firewall-cmd --list-all --zone=$zones | grep ports | grep 'udp\|tcp' | awk -F"ports:" '{print$2}' | sed -E -e 's/[[:blank:]]+/\n/g' | sed '/^$/d' > ports.list
  while read port
  do
    firewall-cmd --permanent --zone=$zones --remove-port=$port
  done < ports.list

  firewall-cmd --list-all --zone=$zones | grep services | awk -F"services:" '{print$2}' | sed -E -e 's/[[:blank:]]+/\n/g' | sed '/^$/d' > services.list
  while read service
  do
    firewall-cmd --permanent --zone=$zones --remove-service=$service
  done < services.list
done < zones.list

bash bash_firewalld_rules_export.sh

rm -rf ./*.list
