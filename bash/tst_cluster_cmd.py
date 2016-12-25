#!/usr/bin/python
# encoding: utf-8
'''
t_cluster_cmd 

用于在集群中的主机节点执行命令

@author: vman 

'''
import sys
import os
import commands
import time
from argparse import ArgumentParser
from argparse import RawDescriptionHelpFormatter

PASSWD='password'

def debug( msg):
		# yellow bold green
		print '\033[1;33;93m' + '==> [DEBUG]:' + '\033[0m' 
		print '\033[0;32;92m' + msg + '\033[0m'
		
def info( msg):
		print '\033[1;33;93m' + '==> [INFO]:' + '\033[0m' 
		# green
		print '\033[0;32;92m' + msg + '\033[0m'
	
def err( msg):
		# red bold green
		print '\033[1;33;91m' + '==> [ERROR]:' + '\033[0m' 
		print '\033[0;32;91m' + msg + '\033[0m'

def get_parser(name, desc):
	parser = ArgumentParser(
		prog = name,
		description = desc,
		formatter_class = RawDescriptionHelpFormatter
		)
	parser.add_argument('-e', '--env', default='acloud', choices=['acloud','vs'], help='设置cmd的执行环境，默认是acloud，可选vs')
	# 指定执行节点类型
	parser.add_argument('-n', '--node', default='all', choices=['all','controller','compute','network'], help='指定要执行cmd的节点类型，默认是所有节点，可选控制节点、网络节点、计算节点')
	parser.add_argument('-c', '--cmd', help='需要执行的命令cmd', required=True)
	return parser.parse_args()
	
def get_cmd(env, cmd):
	if (env == 'vs'):
		cmd_new  = 'chroot /sf/vs-acloud/vs-env %s' % cmd
	else:
		cmd_new = cmd
        #debug('CMD is %s.'%cmd_new)
	return cmd_new

def get_nodes_list(node_type):
	if node_type == 'all':
		str_cmd = "/etc/puppet/modules/vt-cloud/show-nodes-ip.sh | awk '(NR>1){print $1}'"
	else:
		str_cmd = "/etc/puppet/modules/vt-cloud/show-nodes-ip.sh | grep %s | awk '{print $1}'" % (node_type)
		
	(status, output) = commands.getstatusoutput(str_cmd)
	
	if (status != 0):
		err( 'cannot find any node with type %s, please check again!' % node_type )
		sys.exit(-1)
	else:
		#print 'nodes_list is %s' % output
		return output.split('\n')

def test_ssh_conn_isok(host, passwd):
	ssh_cmd = 'sshpass -p %s ssh -o StrictHostKeyChecking=no' \
          ' root@%s date 1>/dev/null '%(passwd, host)
	(status,output) = commands.getstatusoutput(ssh_cmd)
	if status == 0:
		return True
	else:
		err( 'cannot connect to %s with %s by SSH, please check again!' % (host, passwd) ) 
		return False


if __name__ == "__main__":  
	pro_name = os.path.basename(sys.argv[0])
	pro_desc = __import__('__main__').__doc__.split("\n")[1]
	
    args = get_parser(pro_name, pro_desc)
    env = args.env or 'acloud'
	node_type = args.node or 'all'

	cmd = get_cmd(env, args.cmd)
	for host in get_nodes_list(node_type):
		if test_ssh_conn_isok(host, PASSWD):
			print '---------------------------------------------------------------------------------------------------------'
			info( 'root@%s # %s'%(host,cmd) )
			str_cmd = 'sshpass -p %s ssh -o StrictHostKeyChecking=no' \
					  ' root@%s %s 2>/dev/null' % (PASSWD, host, cmd)
			#debug( 'CMD is %s' %str_cmd )
			(status,output) = commands.getstatusoutput(str_cmd)
			if status == 0:
				#debug( 'sucess! status is %s , and output is :' % status)
				print output
			else:
				err( 'fail! status is %s , please check! the output is ' % status )
				print output or 'None'
		time.sleep(1)
	sys.exit(0)
