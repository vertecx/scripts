# EventLog
Scripts to fix warnings and errors that appear in the Windows event log.

## CAPI2 error 513
Typical error message:
```
Cryptographic Services failed while processing the OnIdentity() call in the System Writer Object.

Details:
AddLegacyDriverFiles: Unable to back up image of binary Microsoft Link-Layer Discovery Protocol.

System Error:
Access is denied.
```

CAPI2-513.ps1 automates the solution written by szz743 on [Microsoft Community](http://answers.microsoft.com/en-us/windows/forum/windows8_1-hardware/cryptographic-services-failed-while-processing-the/c4274af3-79fb-4412-8ca5-cee721bda112).
The script was created and used on Windows 10. You might find the [SDDL reference](https://msdn.microsoft.com/en-us/library/windows/desktop/aa379570(v=vs.85).aspx) useful when using the script.

**Syntax:** `.\CAPI2-513.ps1 -Service <String>`

| Binary name                             | Service name |
| --------------------------------------- |------------- |
| Microsoft Link-Layer Discovery Protocol | MsLldp       |
