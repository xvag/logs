import tempfile, os, sys, smtplib, ssl

smtp_server = "smtp.gmail.com"
port = 58  # 465 for SSL / 587 For starttls
sender_email = "sender@hostmail.yo"
receiver_email = "receiver@mail.yo"
message = """\
Subject: Hi there

This message is sent from Python."""
password = input("Type your password and press enter: ")
errormsg = None

# Create a secure SSL context
context = ssl.create_default_context()

try:
    server = smtplib.SMTP(smtp_server,port)
    #server.set_debuglevel(1)
    server.ehlo() # Can be omitted
    server.starttls(context=context) # Secure the connection
    server.ehlo() # Can be omitted
    server.login(sender_email, password)
    # TODO: Send email here
    server.sendmail(sender_email, receiver_email, message)
except smtplib.SMTPException as e:
    # Print any error messages to stdout
    errormsg = e.args # print(e)
    print(errormsg)
finally:
    server.quit()
