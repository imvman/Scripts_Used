#!/usr/bin/python
# -*- coding: utf-8 -*-
'''
tst_volumes.py

该脚本供测试云磁盘时使用,请在控制节点上执行,用于查询或设置云磁盘(volume)的状态

@author: vman 

'''
import os,sys
import MySQLdb
from argparse import ArgumentParser
from argparse import RawDescriptionHelpFormatter

def debug(msg):
    # yellow bold green
    print '\033[1;33;93m' + '==> [DEBUG]:' + '\033[0m'
    print '\033[0;32;96m' + msg + '\033[0m'


def info(msg):
    print '\033[1;33;93m' + '==> [INFO]:' + '\033[0m'
    # green
    print '\033[0;32;92m' + msg + '\033[0m'


def err(msg):
    # red bold green
    print '\033[1;33;91m' + '==> [ERROR]:' + '\033[0m'
    print '\033[0;32;91m' + msg + '\033[0m'


def get_parser(name, desc):
    parser = ArgumentParser(
        prog=name,
        description=desc,
        formatter_class=RawDescriptionHelpFormatter
    )
    parser.add_argument('-i', '--id', help='volume ID，必选参数', required=True)
    # 指定执行节点类型
    parser.add_argument('-s',
                        '--status',
                        help='''volume status,
                        云磁盘使用状态，
                        参数未设置时仅查询不更新''',
                        choices=['available', 'in-use', 'deleting', 'creating', 'error', 'offline', 'error_extending',
                                 'error_deleting', 'attaching', 'detaching', 'extending'],
                        )
    parser.add_argument('-a',
                        '--attach_status',
                        help='''volume attach_status,
                        云磁盘挂载状态，
                        参数未设置时仅查询不更新''',
                        choices=['attached', 'detached'],
                        )
    return parser.parse_args()

if __name__ == "__main__":
    pro_name = os.path.basename(sys.argv[0])
    pro_desc = __import__('__main__').__doc__#.split("\n")[1]
    args = get_parser(pro_name, pro_desc)
    vol_id = args.id
    vol_status = args.status
    vol_attach_status = args.attach_status

    query_sql = "select id,display_name,status,attach_status from volumes where id=\'%s\'" % vol_id
    if vol_status is None and vol_attach_status is None:
        sql = query_sql
    elif vol_status and vol_attach_status is None:
        sql = "update volumes set status=\'%s\' where id=\'%s\'" % (vol_status, vol_id)
    elif vol_status is None and vol_attach_status:
        sql = "update volumes set attach_status=\'%s\' where id=\'%s\'" % (vol_attach_status, vol_id)
    else:
        sql = "update volumes set status=\'%s\', attach_status=\'%s\' where id=\'%s\'" % (vol_status, vol_attach_status, vol_id)

    try:
        db = MySQLdb.connect(host='localhost', port=3306, user='root', passwd='adminroot', db='cinder')
        cur = db.cursor()

        #cur.scroll(0, 'absolute')
        debug(sql)
        cur.execute(sql)
        db.commit()

        cur.execute(query_sql)
        data = cur.fetchone()
        if data :
            info("[volume info now] \n\tid: %s \n\tname: %s  \n\tstatus: %s \n\tattach_status: %s" % data)
        else:
            err("404 No data found!")

        cur.close()
        db.close()
    except MySQLdb.Error, e:
        try:
            sqlError = "Error %d:%s" % (e.args[0], e.args[1])
        except IndexError:
            print "MySQL Error:%s" % str(e)

# update_sql = "update volumes set status=%s where id="5b32ea50-dd22-4b93-97c0-865af8f6f535"
