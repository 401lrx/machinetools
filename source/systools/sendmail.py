#!/usr/bin/env python
# -*- coding: UTF-8 -*-
import sys
import argparse

import smtplib
import os
from email.mime.text import MIMEText
from email.header import Header
from email.mime.multipart import MIMEMultipart

def get_parser():
    parser = argparse.ArgumentParser(sys.argv[0])
    parser.add_argument("--sender", required=True, help="The sender of email")
    parser.add_argument("--mailhost", required=True, help="The mailing service hostname")
    parser.add_argument("--mailuser", required=True, help="The username of mailing service")
    parser.add_argument("--mailpass", required=True, help="The password of the user")
    parser.add_argument("-t", "--recipient", required=True, action="append", help="The recipients og email", default=[])
    parser.add_argument("-m", "--message", help="The message body", default="")
    parser.add_argument("-s", "--subject", help="The subject of the email", default="")
    parser.add_argument("-f", "--file", help="attached file", action="append", default=[])
    return parser

def main():
    parser = get_parser()
    args = parser.parse_args()

    mail_host = args.mailhost
    mail_user = args.mailuser
    mail_pass = args.mailpass
    sender = args.sender
    receivers = args.recipient
    mail_file = args.file
    mail_message = args.message
    mail_subject = args.subject

    if sender == "" or len(receivers) == 0:
        parser.print_help()
        exit()

    msgRoot = MIMEMultipart()
    msgRoot['From'] = sender
    msgRoot['To'] =  ",".join(str(i) for i in receivers)
    msgRoot['Subject'] = Header(mail_subject, 'utf-8')

    txtatt=MIMEText(mail_message, 'plain', 'utf-8')
    msgRoot.attach(txtatt)

    try:
        for file_path in mail_file:
            send_file = open(file_path, "rb").read()
            fileatt = MIMEText(send_file, "base64", "utf-8")
            fileatt['Content-Type'] = 'application/octet-stream'
            fileatt['Content-Disposition'] = "attachment;filename=" + os.path.basename(file_path)
            msgRoot.attach(fileatt)
    except Exception as e:
        print(e)
        exit()

    # 发送邮件
    try:
        smtpObj = smtplib.SMTP_SSL(mail_host, 465)
        smtpObj.login(mail_user,mail_pass)  
        smtpObj.sendmail(sender, receivers, msgRoot.as_string())
        print("Send OK")
    except smtplib.SMTPException as e:
        print("Error: sendmail: %d" % e)

if __name__ == '__main__':
    main()