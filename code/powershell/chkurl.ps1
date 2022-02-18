[string] $_URL = 'http://url_to_check'

function CheckSiteURLStatus($_URL) {
try {
$request= [System.Net.WebRequest]::Create($_URL)
$response = $request.getResponse()
if ($response.StatusCode -eq "200") {
write-host "`nSite - $_URL is up (Return code: $($response.StatusCode) -
$([int] $response.StatusCode)) `n" -ForegroundColor green
If ($response -eq $null) { }
Else { $response.Close() }
}
else {
write-host "`n Site - $_URL is down `n" ` -ForegroundColor red
If ($response -eq $null) { }
Else { $response.Close() }
}
} catch {
write-host "`n Site is not accessable, May DNS issue. Try again.`n" ` -ForegroundColor red
If ($response -eq $null) { }
Else { $response.Close() }
}
}

CheckSiteURLStatus $_URL

If ($response -eq $null) { }
Else { $response.Close() }
