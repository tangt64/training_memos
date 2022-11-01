$ if4.sh
if cd /usr/local/mysql ; then
  printf >&2 'Changed to primary directory'
elif cd /opt/mysql ; then
  printf >&2 'Changed to secondary directory'
else
  printf >&2 'Cound'\''t find a directory!'
  exit 1
fi