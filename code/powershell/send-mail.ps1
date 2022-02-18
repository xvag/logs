# $From = "from@exampe.com"
# $To = "to@example.com"
# $Cc = ""
# $Attachment = "C:\users\Username\Documents\SomeTextFile.txt"
# $Subject = "Test - Ignoe"
# $Body = "This is a test mail sent from Poweshell"
# $SMTPServer = "smtp.gmail.com"
# $SMTPPort = "587"
# Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential (Get-Credential) -Attachments $Attachment –DeliveryNotificationOption OnSuccess



# $Username = "sendermail@hostmail.com";
# $Password = "password";
# $path = "text1.txt";
#
# function Send-ToEmail([string]$email, [string]$attachmentpath){
#
#     $message = new-object Net.Mail.MailMessage;
#     $message.From = "csrv.lab@gmail.com";
#     $message.To.Add($email);
#     $message.Subject = "subject text here...";
#     $message.Body = "body text here...;sadofks;ogfsogfspofi
# 	safoisdjflisajf
# 	sdfoisdjfisdjfidsjf";
#     $attachment = New-Object Net.Mail.Attachment($attachmentpath);
#     $message.Attachments.Add($attachment);
#
#     $smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", "587");
#     $smtp.EnableSSL = $true;
#     $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
#     $smtp.send($message);
#     write-host "Mail Sent" ;
#     $attachment.Dispose();
#  }
#
# Send-ToEmail -email "receiver@hostmail.com" -attachmentpath $path;


$Username = "sendermail@hostmail.com";
$Password = "password";

function Send-ToEmail([string]$email){

    $message = new-object Net.Mail.MailMessage;
    $message.From = "sendermail@hostmail.com";
    $message.To.Add($email);
    $message.Subject = "subject text here...";
    $message.Body = "message body here";

    $smtp = new-object Net.Mail.SmtpClient("smtp.hostmail.com", "587");
    $smtp.EnableSSL = $true;
    $smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
    $smtp.send($message);
    write-host "Mail Sent" ;
 }

Send-ToEmail -email "receivermail@hostmail.com";
