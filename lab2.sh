memu

function menu(){
    clear
    echo 
    echo -e "\t\t\tHTTP MENU\n"
    echo -e "\t1. Control Httpd Service"
    echo -e "\t2. Create to the \"index.html\"" 
    echo -e "\t3. Check the httpd.service"
    echo -e "\t0. Exit Program\n\n"
    echo -e "\t\Enter Number: "
    read -n 1 option
}



function DeleteHtmlDir(){
while true; do
    read -p "Do you want to delete? (y/n)" yn

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


function CreateIndexHtml(){

    echo "Hello World" >> $location/index.html
}


function IsActiveHttpService(){

if [ -d $location ]
then
    if (!systemctl is-active httpd && !rpm -qa | grep httpd 1> /dev/null)
    then
        echo "the httpd service is started"
    else
        echo "the httpd service is stopped"
fi

}