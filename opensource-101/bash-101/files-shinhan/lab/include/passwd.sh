
function SetUserPasswd() {
  local uname=$1
  local upasswd=$2
  
  echo $upasswd | passwd --stdin $uname
  if [[ $? -eq 0 ]] ; then
    echo "the user $uname has been chanaged"
  else
    echo "can't change the user $uname password"
  fi
}
