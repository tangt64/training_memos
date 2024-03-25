PS3="Select your a httpd task please: "
select t_cmd in check start failed exit delete install
do
  case $t_cmd in
    delete)
      delete_httpd
      ;;
    install)
      install_httpd
      ;;
  esac
done

