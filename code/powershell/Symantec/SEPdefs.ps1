# - Download SEP definitions based on today's date.
# - If not available, download yesterday's definitions.
# - If successful, create new New Definitions .zip.
# - Sent email notification.

# Function to check file size

Function Format-FileSize() {
Param ([int]$size)
If ($size -gt 1TB) {[string]::Format("{0:0.00} TB", $size / 1TB)}
ElseIf ($size -gt 1GB) {[string]::Format("{0:0.00} GB", $size / 1GB)}
ElseIf ($size -gt 1MB) {[string]::Format("{0:0.00} MB", $size / 1MB)}
ElseIf ($size -gt 1KB) {[string]::Format("{0:0.00} kB", $size / 1KB)}
ElseIf ($size -gt 0) {[string]::Format("{0:0.00} B", $size)}
Else {""}
}

# Email Function & Variables

	$Username = "mail-username";
	$Password = "mail-password";
	$mailsubject = "SEP Definitions Update: SUCCESS"
	$global:mailbody = "SEP Definitions Update - $(Get-Date) `n`n"

Function Send-Email([string]$email, [string]$subject, [string]$body){

	$message = new-object Net.Mail.MailMessage;
	$message.From = "mail-sender";
	$message.To.Add($email);
	$message.Subject = $subject;
	$message.Body = $body;

	$smtp = new-object Net.Mail.SmtpClient("smtp.host.com", "587");
	$smtp.EnableSSL = $true;
	$smtp.Credentials = New-Object System.Net.NetworkCredential($Username, $Password);
	$smtp.send($message);
	write-host "Mail Sent" ;
}


# Function to Download Definitions

Function Download-SEP-Definitions($_URL) {
try {
	$request = [System.Net.WebRequest]::Create($_URL)
	$response = $request.getResponse()

	if ($response.StatusCode -eq "200") {
		write-host "`n $_URL - OK `n" -ForegroundColor green

		switch ($i) {
			0 {
				Invoke-WebRequest -Uri $_URL -Outfile $defs\SEP12-32bit-Definitions-$defdate.exe -UseBasicParsing
				$global:mailbody += "Definitions for SEP 12 (32-bit): $defdate - OK `n $_URL `n`n"
				#$global:success++
			}
			1 {
				Invoke-WebRequest -Uri $_URL -Outfile $defs\SEP12-64bit-Definitions-$defdate.exe -UseBasicParsing
				$global:mailbody += "Definitions for SEP 12 (64-bit): $defdate - OK `n $_URL `n`n"
				#$global:success++
			}
			2 {
				Invoke-WebRequest -Uri $_URL -Outfile $defs\SEP14-32bit-Definitions-$defdate.exe -UseBasicParsing
				$global:mailbody += "Definitions for SEP 14 (32-bit): $defdate - OK `n $_URL `n`n"
				#$global:success++
			}
			3 {
				Invoke-WebRequest -Uri $_URL -Outfile $defs\SEP14-64bit-Definitions-$defdate.exe -UseBasicParsing
				$global:mailbody += "Definitions for SEP 14 (64-bit): $defdate - OK `n $_URL `n`n"
				#$global:success++
			}
		}

		If ($response -eq $null) { }
		Else { $response.Close() }
		return 0
	}
	else {
		$global:mailbody += "`n $_URL is down `n"
		If ($response -eq $null) { }
		Else { $response.Close() }
		return 1
	}
} catch {
	$global:mailbody += "`n $_URL - NOT FOUND `n"
	If ($response -eq $null) { }
	Else { $response.Close() }
	return 1
	}
}


# Variable Declarations & Initialization
$i = 0
#$global:success = 0
$defdate = $(Get-Date).ToString("yyyyMMdd")

$sepurl = @("http://definitions.symantec.com/defs/$defdate-023-v5i32.exe",
			"http://definitions.symantec.com/defs/$defdate-023-v5i64.exe",
			"http://definitions.symantec.com/defs/$defdate-023-core3sdsv5i32.exe",
			"http://definitions.symantec.com/defs/$defdate-023-core3sdsv5i64.exe")

$defs = New-Item -ItemType Directory -Force -Path ".\SEPDefinitions"

# Main Part - Downloading the definitions
Foreach ($url in $sepurl) {

	$flag = Download-SEP-Definitions $url

	if ($flag -eq 1) {

		$defdate = $(Get-Date).AddDays(-1).ToString("yyyyMMdd")

		switch ($i) {
			0 {$url = "http://definitions.symantec.com/defs/$defdate-023-v5i32.exe"}
			1 {$url = "http://definitions.symantec.com/defs/$defdate-023-v5i64.exe"}
			2 {$url = "http://definitions.symantec.com/defs/$defdate-023-core3sdsv5i32.exe"}
			3 {$url = "http://definitions.symantec.com/defs/$defdate-023-core3sdsv5i64.exe"}
		}

		$flag = Download-SEP-Definitions $url

		if ($flag -eq 1) {
			break;
		}

		$defdate = (Get-Date).ToString("yyyyMMdd")
	}

	$i++

}

# If all four definitions have been downloaded successfully, continue:
if ($i -eq 4) {

	# Create a zip of the definitions
	Compress-Archive -Path "$defs" -Force -DestinationPath ".\SEP_Definitions.zip"
	$zipfile = ".\SEP_Definitions.zip"
	$zipsize = Format-FileSize((Get-Item $zipfile).length)
	$global:mailbody += "`n New SEP_Definitions.zip has been created successfully. [$zipsize]`n"

} else {

	# Create email notification about failure
	$mailsubject = "SEP Definitions Update: FAIL"
	$global:mailbody += "`n SEP Definitions Update `n $date `n FAILED`n"

}

# Sent email notification
Send-Email -email "mail-receiver" -subject $mailsubject -body $global:mailbody;
