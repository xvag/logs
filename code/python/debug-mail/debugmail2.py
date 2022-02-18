import tempfile, os, sys, smtplib, ssl

# Find an available file descriptor
t = tempfile.TemporaryFile()
available_fd = t.fileno()
t.close()

# now make a copy of stderr
os.dup2(2,available_fd)

# Now create a new tempfile and make Python's stderr got to that file
t = tempfile.TemporaryFile()
os.dup2(t.fileno(),2)

smtp_server = "smtp.hostmail.com"
port = 587  # 465 for SSL / 587 For starttls
sender_email = "sender@hostmail.yo"
receiver_email = "receiver@mail.yo"
message = """\
Subject: Hi there

This message is sent from Python."""
password = input("Type your password and press enter: ")

# Create a secure SSL context
context = ssl.create_default_context()

try:
    server = smtplib.SMTP(smtp_server,port)
    server.set_debuglevel(1)
    server.ehlo() # Can be omitted
    server.starttls(context=context) # Secure the connection
    server.ehlo() # Can be omitted
    server.login(sender_email, password)
    # TODO: Send email here
    server.sendmail(sender_email, receiver_email, message)
except Exception as e:
    # Print any error messages to stdout
    print(e)
finally:
    server.quit()

# Grab the stderr from the temp file
sys.stderr.flush()
t.flush()
t.seek(0)
stderr_output = t.read()
t.close()

# Put back stderr
os.dup2(available_fd,2)
os.close(available_fd)

# Finally, demonstrate that we have the stderr_output
print("STDERR:")
count = 0
for line in stderr_output.decode('utf-8').split("\n"):
    count += 1
    print("{:3} {}".format(count,line))
