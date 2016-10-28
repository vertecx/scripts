Param (
	[int]$Device = 0,
	[int]$WarningTemperature = 60,
	[int]$ShutdownTemperature = 75
)

Set-Variable -Option Constant -Name LogName -Value 'Intel SSD 910'
Set-Variable -Option Constant -Name LogSource -Value 'SSD910Monitor'

New-EventLog -LogName $LogName -Source $LogSource -ErrorAction SilentlyContinue

try {
	$output = isdct.exe -device $Device -drive all -log 0x0D
} catch {
	Write-EventLog -LogName $LogName -Source $LogSource -EventId 5 -EntryType Error -Category 2 -Message 'Could not start isdct.exe. Is the directory containing isdct.exe added to system path?'
	exit 5
}

if ($output -like '*ERROR: Invalid PCIe Device index.*') {
	Write-EventLog -LogName $LogName -Source $LogSource -EventId 6 -EntryType Error -Category 2 -Message 'Could not detect device! Is the script run using sufficient privileges? Is the isdct compatible driver (Version 2.0.60.83 dated 2014-05-14) installed?'
	exit 6
} else {
	# Two out of three words in the isdct output are misspelled...
	$temperatures = $output | Select-String '\| Termperature \(Degress Celsius\)\s*\| (\d*)' -AllMatches | % { $_.Matches.Groups[1].Value }

	if ($temperatures.Length -lt 2) {
		Write-EventLog -LogName $LogName -Source $LogSource -EventId 7 -EntryType Error -Category 2 -Message 'Less than two temperatures were found in the isdct output.'
		exit 7
	} else {
		$max = $temperatures | Measure-Object -Maximum | % { $_.Maximum }

		if ($max -ge $ShutdownTemperature) {
			Write-EventLog -LogName $LogName -Source $LogSource -EventId 3 -EntryType Error -Message "Temperatures: $temperatures (Critical! Hotter than $ShutdownTemperature. Shutting down!)"
			Start-Sleep -Seconds 6
			Stop-Computer -Force
		} elseif ($max -ge $WarningTemperature) {
			Write-EventLog -LogName $LogName -Source $LogSource -EventId 2 -EntryType Warning -Message "Temperatures: $temperatures (Warning! Hotter than $WarningTemperature.)"
		} else {
			Write-EventLog -LogName $LogName -Source $LogSource -EventId 1 -EntryType Information -Message "Temperatures: $temperatures (OK)"
		}
	}
}
