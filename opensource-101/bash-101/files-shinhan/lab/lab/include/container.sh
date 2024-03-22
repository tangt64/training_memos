function CreateContainer(){

  local conimage=$1
  local conname=$2
  
  if [[ $(podman images --noheading | grep $conimage | wc -l) -eq 1 ]] ; then
    podman run -d --rm --name $conname -p 8080:8080 -p 9990:9990 -it $conimage /opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 1> /dev/null
    sleep 10
    curl --silent localhost:8080 -o /tmp/wildfly-index.html 
  else
    podman pull 1> /dev/null
    podman run -d --rm --name $conname -p 8080:8080 -p 9990:9990 -it quay.io/wildfly/$conimage /opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 1> /dev/null
    sleep 10
    curl --silent localhost:8080 -o /tmp/wildfly-index.html
  fi

  if [ -f /tmp/wildfly-index.html ] ; then
    echo "the wildfly container is running"
  else
    echo "the wildfly container is not running"
  fi
}
