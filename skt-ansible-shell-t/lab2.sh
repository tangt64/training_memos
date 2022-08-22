#!/bin/bash

location=/var/www/html

function DeleteHtmlDir(){
clear
while true; do
    read -p "Do you want to delete? (yes/no)" yn

    case $yn in
        [yY]) rm -rf $location && echo "the $location deleted";
            break;;
        [nN]) echo exiting...;
            exit;;
        * ) echo invalid response;
    esac
done
}

function StartHttpService(){
clear
while true; do
    read -p "What do you want to do to the Apache?" srss

    case $srss in
        start) systemctl start httpd && echo "the Apache is started."
        break;;
        stop) systemctl stop httpd && echo "the Apache is stopped."
        break;;
        restart) systemctl restart httpd && echo "the Apache is restarted."
        break;;
        status) systemctl status httpd && echo "shows the status"
        exit;;
        * ) echo invalid response;
    esac
done

}

function menu(){
    clear
    echo
    echo -e "\t\t\tHTTP MENU\n"
    echo -e "\t1. Control Httpd Service"
    echo -e "\t2. Create to the \"index.html\""
    echo -e "\t3. Check the httpd.service"
    echo -e "\t0. Exit Program\n\n"
    echo -e "\t\t Enter Number: "
    read -n 1 option
}


while [ 1 ]
do
  menu
  case $option in
  0)
      break ;;
  1)
      DeleteHtmlDir ;;
  2)
      StartHttpService ;;
  3)
      CreateIndexHtml ;;
  4)
      IsActiveHttpService ;;
  *)
  clear
  echo "Sorry, wrong selection";;
  esac
  echo -en "\n\n\t\t\tHit any key to continue"
  read -n 1 line
done
clear
