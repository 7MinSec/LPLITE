# A quick script to batch enable or disable students for
# Light Pentest LITE (Live Interactive Training Experience)
#
# More information at https://7minsec.com/services/training/#lplite

$confirmation = Read-Host "Do you need to DISABLE all students except student1?"
if ($confirmation -eq 'y') {
disable-adaccount student2
disable-adaccount student3
disable-adaccount student4
disable-adaccount student5
disable-adaccount student6
disable-adaccount student7
}

$confirmation = Read-Host "Do you need to ENABLE all students?"
if ($confirmation -eq 'y') {
enable-adaccount student1
enable-adaccount student2
enable-adaccount student3
enable-adaccount student4
enable-adaccount student5
enable-adaccount student6
enable-adaccount student7
}