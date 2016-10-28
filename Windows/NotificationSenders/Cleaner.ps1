Add-Type -Path "Bin\System.Data.SQLite.dll"

$conn = New-Object -TypeName System.Data.SQLite.SQLiteConnection
$conn.ConnectionString = "Data Source=$env:LOCALAPPDATA\Microsoft\Windows\Notifications\wpndatabase.db"
$conn.Open()

$query = @"
	SELECT HandlerSettings.HandlerId, NotificationHandler.PrimaryId FROM HandlerSettings
	JOIN NotificationHandler ON HandlerSettings.HandlerId = NotificationHandler.RecordId
	WHERE HandlerSettings.SettingKey = 's:toast' AND HandlerSettings.Value = 0 AND NotificationHandler.HandlerType = 'app:desktop'
"@

$sql = $conn.CreateCommand()
$sql.CommandText = $query
$data = New-Object System.Data.DataSet
$adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $sql
$adapter.Fill($data) | Out-Null

$title = "The following notification sending desktop apps are disabled. Proceed with deletion?"
$message = $data.Tables.Rows | Out-String
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Deletes disabled notification senders."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Keep disabled notification senders."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 1)

if ($result -eq 0) {
	$data.Tables.Rows | ForEach-Object {
		Write-Host "`nDeleting $($_.HandlerId) $($_.PrimaryId):"

		Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\NotifyIcon\$($_.PrimaryId).png" -ErrorAction SilentlyContinue -ErrorVariable err
		if ($err) {
			Write-Host "Icon: Does not exist or delete failed."
		} else {
			Write-Host "Icon: Deleted"
		}

		Remove-Item -Path "hkcu:\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\$($_.PrimaryId)" -ErrorAction SilentlyContinue -ErrorVariable err
		if ($err) {
			Write-Host "Registry key: Does not exist or delete failed."
		} else {
			Write-Host "Registry key: Deleted"
		}

		$sql.CommandText = "DELETE FROM NotificationHandler WHERE RecordId = $($_.HandlerId)"
		Write-Host "NotificationHandler: Deleted $($sql.ExecuteNonQuery()) lines"
		$sql.CommandText = "DELETE FROM Notification WHERE HandlerId = $($_.HandlerId)"
		Write-Host "Notification: Deleted $($sql.ExecuteNonQuery()) lines"
		$sql.CommandText = "DELETE FROM HandlerSettings WHERE HandlerId = $($_.HandlerId)"
		Write-Host "HandlerSettings: Deleted $($sql.ExecuteNonQuery()) lines"
		$sql.CommandText = "DELETE FROM WNSPushChannel WHERE HandlerId = $($_.HandlerId)"
		Write-Host "WNSPushChannel: Deleted $($sql.ExecuteNonQuery()) lines"
	}
}

$sql.Dispose()
$conn.Close()
