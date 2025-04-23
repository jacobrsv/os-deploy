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
$WinName = Get-CimInstance win32_operatingsystem | % caption
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
$Uri = "http://os-deploy.internal/"
$Body = @{
    SerialNumber = $SerialNumber
    UUID = $UUID
    IPAddresses = $IPAddresses -join ', '
    MACAddresses = $MACAddresses -join ', '
    WindowsInfo = $WindowsInfo
    ComputerName = $ComputerName
}
$JsonBody = $Body | ConvertTo-Json -Depth 10
Invoke-RestMethod -Uri $Uri -Method Post -Body $JsonBody -ContentType "application/json"
