# $zipfile = '.\archive\lab.zip'
# $files = 'text2.txt'
# 
# $stream = New-Object IO.FileStream($zipfile, [IO.FileMode]::Open)
# $mode = [IO.Compression.ZipArchiveMode]::Update
# $zip = New-Object IO.Compression.ZipArchive($stream, $mode)
# 
# ($zip.Entries | ? { $files -contains $_.Name}) | % { $_.Delete() }
# 
# $zip.Dispose()
# $stream.Close()
# $stream.Dispose()

Compress-Archive -Path .\lab\*.* -DestinationPath .\archive\lab.zip