#!/bin/bash

for CreateUser in helix jay syndy jeff
do
   adduser $CreateUser 2> /dev/null
done

jeff=$(grep ^jeff /etc/passwd | awk -F: '{ print $1 }')
jay=$(grep ^jay /etc/passwd | awk -F: '{ print $1 }')


if [[ $jeff == jeff ]]
then
echo "Welcome to jeff!!"
fi

if [ $jay == jay ]
then
echo "Welcome to jay!!"
fi


echo $(grep ^http /etc/services | head -1 | awk '{ print $1, $2 }')
echo $(grep ^ssh /etc/services | head -1 | awk '{ print $1, $2 }')
