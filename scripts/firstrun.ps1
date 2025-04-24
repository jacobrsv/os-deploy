# Find serienummeret
$SerialNumber = (Get-WmiObject -Class Win32_BIOS).SerialNumber
Write-Output "Serial Number: $SerialNumber"

# Hent UUID
$UUID = (Get-WmiObject -Class Win32_ComputerSystemProduct).UUID
Write-Output "UUID: $UUID"

# Hent IP addressen
$IPAddresses = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1"}).IPAddress
Write-Output "IP Addresses: $($IPAddresses -join ', ')"

# Hente MAC addressen på det netværkskort som er "oppe"
$MACAddresses = (Get-NetAdapter | Where-Object {$_.Status -eq "Up"}).MacAddress
Write-Output "MAC Addresses: $($MACAddresses -join ', ')"

# Windows name
$WinName = "CONTOSO-$SerialNumber"
Write-Output "Windows name: $WinName"

# Windows build
$BuildVersion = (Get-CimInstance Win32_OperatingSystem).BuildNumber
Write-Output "Windows Build: $BuildVersion"

# Windows version
$BuildVersion = (Get-CimInstance Win32_OperatingSystem).Version
Write-Output "Windows Version: $BuildVersion"

# Computernavn
$ComputerName = $env:COMPUTERNAME
Write-Output "Computer Name: $ComputerName"

# Post data to web
$URL = "http://osdeploy.internal:8000/add"


Invoke-WebRequest -UseBasicParsing -Uri $URL `
-Method POST `
-ContentType "application/x-www-form-urlencoded" `
-Body "uuid=$UUID&serial_number=$SerialNumber&computer_name=$ComputerName&ip_address=$($IPAddresses -join ',')&mac_address=$($MACAddresses -join ',')&win_name=$WinName&win_ver=$BuildVersion&win_build=$BuildVersion"