#!/bin/sh
GREEN_COL="\\033[32;1m"
RED_COL="\\033[1;31m"
NORMAL_COL="\\033[0;39m"

CURRENT_CNT=0
IMG_LIST=$(cat k8s-images.txt | tr "\n" " ")
IMG_LIST_ARR=($IMG_LIST)
SAVE_LIST=$(sed 's/registry.k8s.io\///g;/#/d;s/:/-/g;s/\//-/g' k8s-images.txt | tr "\n" " ")
SAVE_LIST_ARR=($SAVE_LIST)
skopeo_copy(){
	if skopeo copy docker://$1 docker-archive:$2.tar:$1; 
	then 
		echo -e "$GREEN_COL Progress: ${CURRENT_NUM}/${TOTAL_NUMS} sync $1 to $2 successful $NORMAL_COL"
	else
		echo -e "$RED_COL Progress: ${CURRENT_NUM}/${TOTAL_NUMS} sync $1 to $2 failed $NORMAL_COL"
		exit 2
	fi
}

for i in "${!IMG_LIST_ARR[@]}"; do
	let CURRENT_CNT=${CURRENT_CNT}+1
	skopeo_copy "${IMG_LIST_ARR[i]}" "${SAVE_LIST_ARR[i]}" "${IMG_LIST_ARR[i]}"
done
