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
   info "Usage: $0 path_to_result_file"
   exit 0
fi
# ok
path_to_result_file=$1
if [ -f $path_to_result_file ];then
 rm "$path_to_result_file"
fi
touch "$path_to_result_file"
# 5mins
for ((i=0;i<100;i++)) do
   accinfo -g | awk -v path=$path_to_result_file 'NR==3{print $7 >> path}'
   sleep 3
done
./calc_everage_speed.sh "$path_to_result_file"
   
