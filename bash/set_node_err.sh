#!/bin/bash
hostname=`hostname`
localhost=`grep "$hostname" /etc/hosts | awk '{print $1}'`

host=`gluster peer status | grep "Hostname" | awk -F ": " '{print $2}'`
host_arr=($host)
for i in ${host_arr[@]}
do
 	ip=`grep "$i" /etc/hosts | awk '{print $1}'`
	echo " $i $ip"
	iptables -A OUTPUT -s $localhost -d $ip -j DROP
	echo " Add iptables rules to drop $localhost->$ip."
done
