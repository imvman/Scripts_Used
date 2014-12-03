#!/bin/bash
#common function
function error(){
	echo -e "\033[31m[ERROR]:\033[0m $1"
}
function info(){
	echo -e "\033[33m[INFO]:\033[0m $1"
}
#check arguments
if [ $# -ne 1 ];then
   info "Usage: $0 path_to_file"
   exit 0
fi
# ok
FILE=$1
if [ ! -f $FILE ];then
   error "$FILE does not exist or is not a file!"
   error "Exit!"
   exit -1
fi
#get line num  
line=`cat $FILE | wc -l`
line=$(($line+0))
#info "line: $line"
kb_line=`grep 'KBps' $FILE | wc -l`
kb_line=$(($kb_line+0))
mb_line=`grep 'MBps' $FILE | wc -l`
mb_line=$(($mb_line+0))
#info "kb_line: $kb_line  mb_line:$mb_line"
# change to kbps
if [ $mb_line -lt $kb_line ];then 

        result=`awk -v num=$line 'BEGIN {sum=0;cur=0}{
	if($1 ~ /MBps/){split($1,str,"MBps");cur=1000*str[1];}
        else if($1 ~ /KBps/){split($1,str,"KBps");cur=str[1];}
        else {cur=1;}
        sum+=cur}
	END {print "Speed: "sum/num"KBps"}' $FILE`
else 
#change to mbps
	result=`awk -v num=$line 'BEGIN {sum=0;cur=0}{
        if($1 ~ /MBps/){split($1,str,"MBps");cur=str[1];}
        else if($1 ~ /KBps/){split($1,str,"KBps");cur=str[1]/1000;}
        else {cur=1;}
        sum+=cur}
        END {print "Speed: "sum/num"MBps"}' $FILE`
fi
info "$result"
echo "$result" >> $FILE
