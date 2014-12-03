#!/bin/bash
function usage {
INFO0x00="   USAGE:\n\tSet the transparent mode:"
INFO0x000="\n\t\ttransparent.sh -s ip mode"
INFO0x01="   Such as [transparent.sh -s 202.198.60.66 1],will set the ransparent-node's(in wanacc.conf) value \nto be 1 for gateway with peer_ip 202.198.60.66.Then restart waccd."
INFO0x02="\n\tGet the current transparent mode:"
INFO0x020="\n\t\ttransparent.sh -g ip"
INFO0x03="   Such as [transparent.sh -g 202.198.60.66],will get the transparent-node's(in wanacc.conf) value.\n"
echo -e $INFO0x00
echo -e $INFO0x000 | grep "transparent.sh -s ip mode" --color 
echo -e $INFO0x01 
echo -e $INFO0x02
echo -e $INFO0x020 | grep "transparent.sh -g ip" --color
echo -e $INFO0x03
return 0
}
function checkip {
	gwip=$1
	r=`xmlop -f /etc/sinfor/wanacc/wanacc.conf -node /wanacc/gateways/[gateway:ip=$gwip] exist`	
	if [ "$r" == "0" ];then
		echo -e "[Error] Can't find the gw-connection with ip $gwip.Maybe you should try another ip.\n" | grep --color "Error"
		exit -1
	fi
	return 0	
	}	
	
function checkmode {
	mode=$1
	#echo $mode
	if [ "$mode" != "0" -a "$mode" != "1" -a "$mode" != "2" -a "$mode" != "3" ];then
		echo -e "[Error] Please give the correct para mode[0-3]!\n" | grep --color "Error"
		exit -1
	else 
		echo -e "Will change transparent mode to $mode.\n" | grep --color "$mode"
	fi
}
function getmode {
	ip=$1
	cur_mode=`xmlop -f /etc/sinfor/wanacc/wanacc.conf -node /wanacc/gateways/[gateway:ip=$ip] getattr transparent` 
	echo -e "The current transparent mode is $cur_mode.\n" | grep --color "$cur_mode"
	return $cur_mode
}
function setmode {
	gw_ip=$1
	set_mode=$2
	getmode $1
	if [ "$?" == "$2" ];then 
	   echo -e "The current transparent mode is just what you want,so I won't restart waccd for you.\n"
	   return 0
	fi
	xmlop -f /etc/sinfor/wanacc/wanacc.conf -node /wanacc/gateways/[gateway:ip=$gw_ip] setattr transparent=$set_mode
	if [ $? -ne 0 ];then
	   echo -e "[Error] failed to set transparent mode.\n" | grep --color "Error"
           exit -1
	else
	   echo -e "Have changed transparent mode to $set_mode.Now restart waccd.\n" | grep "$set_mode" --color
	   echo -e "Now restart waccd....\n"
	   /etc/init.d/waccd restart >> /dev/null
          return 0
	fi
}
 
#---------main-------------
#clear
usage 
if [ "$1" == "-h" ];then
	clear
	usage
	exit
fi
if [ $# == 2 ];then
	if [ "$1" == "-g" ];then
		checkip $2 
		getmode $2  
	else
		echo -e "[Error]Read the usage again please!\n" | grep --color "Error"                                  
		exit -1                  
	fi
elif [ $# == 3 ];then
 	if [ "$1" == "-s" ];then
 		checkip $2
		checkmode $3
		setmode $2 $3
		getmode $2
	else	
		echo -e "[Error]Read the usage again please!\n" | grep --color "Error"	
		exit -1
	fi
else
	echo -e "[Error]Read the usage again please!\n" | grep --color "Error"                                  
	exit -1
fi
echo -e "\nNow I've achieved my goal.Bye...I am killing myself...\n"
exit
