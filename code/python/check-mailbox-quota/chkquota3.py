#!/usr/bin/env python
#
# Very basic example of using Python and IMAP to iterate over emails in a
# gmail folder/label.  This code is released into the public domain.
#
# RKI July 2013
# http://www.voidynullness.net/blog/2013/07/25/gmail-email-with-python-via-imap/
#
import sys
import imaplib
import getpass
import email
import email.header
import datetime
import re

# text file containing email creds in the form of:
# mail@nomail.com password imap.hostname.yo
f = open("mail-list.txt")

for line in f:
 creds = line.split()
 #print (creds[0])
 #print (creds[1])
 #+print (creds[2])
 M = imaplib.IMAP4_SSL(creds[2])

 try:
     rv, data = M.login(creds[0], creds[1])
 except imaplib.IMAP4.error:
     print (creds[0], ": LOGIN FAILED!!! ")
     sys.exit(1)

 #print (creds[0],": ",rv, data)

# rv, mailboxes = M.list()
# if rv == 'OK':
#     print ("Mailboxes:")
#     print (mailboxes)

 p = re.compile('\d+')
 quotaStr = M.getquotaroot("INBOX")[1][1][0]
# print (quotaStr)

 r = p.findall(quotaStr.decode('utf8'))

 #print ("Quota for %(username)s@%(server)s:" % (vars(args)))

 if r == []:
     r.append(0)
     r.append(0)

 #print ('Allotted = %f MB'%(float(r[1])/1024))
 #print ('Used = %f MB'%(float(r[0])/1024))
 print (creds[0], ': %f MB/ %f MB\n'%((float(r[0])/1024),(float(r[1])/1024)))
 M.logout()

f.close()
