#!/usr/bin/python
# -*- coding: UTF-8 -*-

import getopt
import sys

import smtplib
import os
from email.mime.text import MIMEText
from email.header import Header
from email.mime.multipart import MIMEMultipart

def usage():
        print ("mysendmail send [params]:")
        print ("    -h --help: 帮助信息")
        print ("    -t --to: 接受邮箱")
        print ("    -m --message: 设置正文")
        print ("    -s --subject: 设置主题")
        print ("    -f --file: 附件，绝对路径")

# 基础设置
mail_host="smtp.qq.com"  #设置服务器
mail_user=""   #用户名
mail_pass=""   #口令 

sender = ''     # 发信人
receivers = []  # 接收人列表

# 解析参数
mail_file_path=""
mail_message=""
mail_subject=""

if len(sys.argv) < 2 or sys.argv[1] != "send":
        usage()
        exit()

opts,args = getopt.getopt(sys.argv[2:], '-h-t:-m:-s:-f:',['help','to','message','subject','file'])
for opt_name,opt_value in opts:
        if opt_name in ('-h','--help'):
                usage()
                exit()
        if opt_name in ('-t','--to'):
                receivers.append(opt_value)
        if opt_name in ('-m','--message'):
                mail_message = opt_value
        if opt_name in ('-s','--subject'):
                mail_subject = opt_value
        if opt_name in ('-f','--file'):
                mail_file_path = opt_value

# 邮件构造
msgRoot = MIMEMultipart()
msgRoot['From'] = Header("cc机器人", 'utf-8')
toMember = ''.join(str(i) for i in receivers)
msgRoot['To'] =  Header(toMember, 'utf-8')

# 邮件主题
msgRoot['Subject'] = Header(mail_subject, 'utf-8')

# 文本附件
txtatt=MIMEText(mail_message, 'plain', 'utf-8')
msgRoot.attach(txtatt)

# 文件附件
if mail_file_path != "":
        send_file = open(mail_file_path, "rb").read()
        fileatt = MIMEText(send_file, "base64", "utf-8")
        fileatt['Content-Type'] = 'application/octet-stream'
        fileatt['Content-Disposition'] = "attachment;filename=" + os.path.basename(mail_file_path)
        msgRoot.attach(fileatt)

# 发送邮件
try:
        smtpObj = smtplib.SMTP() 
        smtpObj.connect(mail_host, 25)    # 25 为 SMTP 端口号
        smtpObj.login(mail_user,mail_pass)  
        smtpObj.sendmail(sender, receivers, msgRoot.as_string())
        print ("Send OK")
except smtplib.SMTPException:
        print ("Error: sendmail")
