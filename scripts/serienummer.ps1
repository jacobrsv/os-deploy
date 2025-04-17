# Finder computerens serienummer og tilføjer en prefix
# f.eks virksomhedsnavn-PF1S604Y
return "CONTOSO-$(Get-CimInstance -ClassName Win32_BIOS | Select-Object -ExpandProperty SerialNumber)"
