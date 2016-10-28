Param (
	[Parameter(Mandatory=$true)]
	[string]$Service
)

$output = (sc.exe sdshow $Service | Out-String).Trim()

if ($output.Contains("FAILED")) {
	Write-Host $output
} elseif ($output.Contains(";SU)")) {
	Write-Host "Service already has NT AUTHORITY\SERVICE ACL"
} else {
	$foundDacl = $false
	$mod = -1
	[System.Collections.ArrayList]$acls = $output.Split(')')

	for ($i = 0; $i -lt $acls.Count; $i++) {
		if ($acls[$i].StartsWith("D:")) {
			$foundDacl = $true
		}

		if ($foundDacl -and $acls[$i].StartsWith("S:")) {
			$mod = 0
			break
		}
	}

	$acls.Insert($i + $mod, "(A;;CCLCSWLOCRRC;;;SU")

	$new = $acls -join ')'

	Write-Host "Original ACL: $output"
	Write-Host "Modified ACL: $new"

	$confirmation = Read-Host "`nDoes the modified ACL look reasonable? (Y/N)"
	if ($confirmation -ieq 'y') {
		$regKey = "HKLM\SYSTEM\CurrentControlSet\Services\$Service\Security"
		$backupFile = Join-Path $env:TEMP "$Service.reg"

		reg.exe export $regKey $backupFile /y

		Write-Host "A backup of $regKey was written to $backupFile."

		sc.exe sdset $Service $new
	}
}
