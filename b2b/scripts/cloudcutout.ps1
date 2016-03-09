[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True,Position=1)][string]$inputdir,
	[Parameter(Mandatory=$True,Position=2)][string]$outputdir,
	[string]$queue = "demo",
	[string]$token = "",
	[string]$url = "https://api.cloudcutout.com/cloudcutout-workflow-job-service/rest"
)
	
Write-Verbose "inputdir: $inputdir"
Write-Verbose "outputdir: $outputdir"
Write-Verbose "token: $token"
Write-Verbose "url: $url"

$files = Get-ChildItem $inputdir -Recurse | Where-Object {$_.Name -match ".*\.(jpg|gif|png|jpeg)"}

Write-Verbose "Looping over $($files.Length) files."
$wc = new-object System.Net.WebClient
$enc = [System.Text.Encoding]::ASCII
foreach ($file in $files ) {
	Write-Verbose $file.fullName
	
	$id=''
	$state=''
	$path=$file.Directory.FullName
	$base=$file.Name
	$db=Join-Path $path ".$($file.BaseName)"
	echo $null >> $db
	$state=(cat $db)
	try {
		$id=$state | Select-Object -first 1
		$status=$state | Select-Object -last 1
	} catch {
		# Write-Verbose $_.Exception.Message
	}
	
	if ($id) {
		$endpoint="${url}/queue/${queue}/${id}/status?token=${token}"
		try {
			$status=(Invoke-RestMethod -Uri $endpoint -method GET)
			echo $id > $db
			echo $status >> $db
		} catch {
			Write-Host "Status update failed"
			Write-Verbose $_.Exception.Message
		}
		if ($status -eq "ok") {
			$endpoint = "${url}/queue/${queue}/${id}?token=${token}"
			$fileurl=(Invoke-RestMethod -Uri $endpoint -method GET)
			$aux1=$fileurl.subString(0,$fileurl.indexOf("?"))
			$ext=$aux1.subString($aux1.lastIndexOf(".")+1,$aux1.Length-$aux1.lastIndexOf(".")-1)
			$output=Join-Path "$outputdir" $file.Name
			$output="$($output.SubString(0,$output.LastIndexOf("."))).$ext"
			mkdir -Force (Split-Path $output)
			# Download file
			try {
				$wc.DownloadFile($fileurl, $output)
				rm $db
				# rm $file
				Write-Host ".. not deleting original file."
			} catch {
				Write-Host "Download failed"
				Write-Verbose $_.Exception.Message
			}
		}
	} else {
		$endpoint="${url}/queue/${queue}/todo?token=${token}&filename=${base}"
		Write-Verbose "endpoint: $endpoint"
		try {
			$resp=($wc.UploadFile($endpoint, $file.FullName))
			$id=$enc.GetString($resp)
			echo $id > $db
		} catch {
			Write-Host "Upload failed"
			Write-Verbose $_.Exception.Message
		}
	}
	echo "$file : $base : $id : $status"
}
