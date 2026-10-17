
# memoria.ps1 — Deber 2, semana 2
$salida = Join-Path $PSScriptRoot "memoria_$env:COMPUTERNAME.txt"
& {
"== Equipo: $env:COMPUTERNAME $(Get-Date -f d)"
"== Arquitectura: $env:PROCESSOR_ARCHITECTURE"
"LittleEndian: $([BitConverter]::IsLittleEndian)"
"== Cachés (KB)"
Get-CimInstance Win32_CacheMemory |
Select-Object Purpose, InstalledSize

"== Conjuntos de cache L1d"
# Valores del AMD Ryzen 5 7520U (Zen 2)
$C = 32 * 1024
$L = 64
$A = 8

$S = $C / ($L * $A)

"Capacidad L1d: $($C / 1024) KiB"
"Tamano de linea: $L bytes"
"Asociatividad: $A vias"
"Conjuntos L1d por nucleo: $S"

# TODO: RAM -> Win32_OperatingSystem

"== Memoria RAM"
$ram = Get-CimInstance Win32_OperatingSystem
"RAM total: $([math]::Round($ram.TotalVisibleMemorySize / 1MB, 2)) GiB"
"RAM libre: $([math]::Round($ram.FreePhysicalMemory / 1MB, 2)) GiB"

# TODO: discos -> Get-PhysicalDisk

"== Discos físicos"
Get-PhysicalDisk | ForEach-Object {
    "Nombre: $($_.FriendlyName)"
    "Tipo: $($_.MediaType)"
    "Capacidad: $([math]::Round($_.Size / 1GB, 2)) GiB"
}


} | Out-File $salida
"Reporte: $salida"
