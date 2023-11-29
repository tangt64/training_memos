#!/bin/bash


echo "#!/bin/bash" > bash_firewalld_rules_export.sh
firewall-cmd --get-zones | sed -E -e 's/[[:blank:]]+/\n/g' > zones.list

while read zones
do
  firewall-cmd --list-all --zone=$zones | grep 'rule family="ipv4"' | sed -e 's/^[ \t]*//' > richrule.list
  sed -i -e 's/$/"/' richrule.list
  sed -i -e 's/^/"/' richrule.list
  sed -i -e "s/^/firewall-cmd --zone=$zones --permanent --add-rich-rule=/" richrule.list
  cat richrule.list >> bash_firewalld_rules_export.sh

  firewall-cmd --list-all --zone=$zones | grep ports | grep 'udp\|tcp' | awk -F"ports:" '{print$2}' | sed -E -e 's/[[:blank:]]+/\n/g' | sed '/^$/d' > ports.list
  sed -i -e "s/^/firewall-cmd --permanent --zone=$zones --add-port=/" ports.list
  cat ports.list >> bash_firewalld_rules_export.sh

  firewall-cmd --list-all --zone=$zones | grep services | awk -F"services:" '{print$2}' | sed -E -e 's/[[:blank:]]+/\n/g' | sed '/^$/d' > services.list
  sed -i -e "s/^/firewall-cmd --permanent --zone=$zones --add-service=/" services.list
  cat services.list >> bash_firewalld_rules_export.sh

done < zones.list

echo "firewall-cmd --reload" >> bash_firewalld_rules_export.sh

rm -rf ./*.list
