###############更改时间、时区




###############ssh免密登录###############
#!/bin/bash
#获取本机ip地址
ipaddr=`/sbin/ifconfig|grep -n1 "Scope:Link" |grep 192.168|awk '/inet addr/ {print $3}'| cut -f2 -d":"|head -1`
#使用ssh-keygen生成密钥，路径为默认路径，空密码
ssh-keygen  -t rsa -P '' -f /root/.ssh/identity
mv /root/.ssh/identity.pub /root/.ssh/identity.pub_$ipaddr

expect << EOF
set timeout 30
#将ssh-keygen生成的公钥identity.pub发送到目标服务器响应文件
spawn scp -oStrictHostKeyChecking=no /root/.ssh/identity.pub_$ipaddr  root@192.168.2.1:/root/.ssh/
expect "password:"
#服务器密码是passwd
send "passwd\r"
expect eof 
EOF

#使用ssh登录到目的服务器
expect << EOF
spawn ssh  root@192.168.2.1
expect "password:"
send "passwd\r"
expect "*#*" {send "cat /root/.ssh/identity.pub_* >> /root/.ssh/authorized_keys\r"}
expect "*#*" {send "rm -rf /root/.ssh/identity.pub_*\r"}
expect eof 
EOF


###############获取本机ip###############
#centos 6
ifconfig eth0|grep "inet addr:"|awk -F":" '{print $2}'|awk '{print $1}'

#centos 7
ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1 -d '/'

或者：
ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | awk -F"/" '{print $1}'
