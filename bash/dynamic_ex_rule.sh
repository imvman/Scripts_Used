#!/bin/sh
usage="Usage: $0 [num]\n\tadd [num] ex_rules,default for 100."
if [[ $1 == "-h" ]];then
	echo -e $usage
	exit 0
fi
if [ $# -gt 1 ];then
	echo -e $usage
	exit -1;
fi
if [ $# -eq 0 ];then
	num=100
 	#echo $num
elif [ $1 -gt 0 ];then
	num=$1
        #echo $num
else
	echo -e $usage
	exit -1;
fi	
randomIp(){
IP="$(($RANDOM%255))"
IP=${IP}.$(($RANDOM%255))
IP=${IP}.$(($RANDOM%255))
IP=${IP}.$(($RANDOM%255))
echo $IP
}
randomPort(){
PORT="$(($RANDOM%10000))"
echo $PORT
}
randomTime(){
TIME="$(($RANDOM%300+30))"
echo $TIME
}
#
echo "enable_ex_rule = 1" > /proc/wnet/wdebug
for((i=1;i<=$num;i++))
do
   sip="$(randomIp)"
   dip="$(randomIp)"
   dport="$(randomPort)" 
   time="$(randomTime)"
   #echo $time
   #echo "[add|delete] sip=xx.xx.xx.xx dip=xx.xx.xx.xx dport=xx timeout=xx" > /proc/wnet/wdebug
   echo "add sip=$sip dip=$dip dport=$dport timeout=$time" > /proc/wnet/wdebug
done
cat /proc/wnet/werrconn | wc -l
exit 0
