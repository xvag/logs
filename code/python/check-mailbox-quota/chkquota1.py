#!/usr/bin/env python
# -*- encoding: utf-8 -*-

import getpass, imaplib, re

def getArgs():
    """show argpase snippets"""
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--username', nargs='?')
    parser.add_argument('-i', '--imap', nargs='?', default= 'imap.gmail.com')
    parser.add_argument('-p', '--password', nargs='?')
    parser.add_argument('-P', '--port', nargs='?', type=int, default=993)

    args = parser.parse_args()
    if not args.username:
        parser.print_usage()
        exit()

    args.server = args.imap.replace('imap.', '')
    if not args.password:
        args.password=getpass.getpass()
    return args

if __name__ == '__main__':

    args = getArgs()
    p = re.compile('\d+')

    IMAP_SERVER=args.imap
    IMAP_PORT=args.port

    IMAP_USERNAME="%(username)s@%(server)s" % (vars(args))

    M = imaplib.IMAP4_SSL(IMAP_SERVER, IMAP_PORT)
    M.login(IMAP_USERNAME, args.password)
    quotaStr = M.getquotaroot("INBOX")[1][1][0]
    r = p.findall(quotaStr)

    print ("Quota for %(username)s@%(server)s:" % (vars(args)))

    if r == []:
        r.append(0)
        r.append(0)

    print ('Allotted = %f MB'%(float(r[1])/1024))
    print ('Used = %f MB'%(float(r[0])/1024))

    M.logout()
