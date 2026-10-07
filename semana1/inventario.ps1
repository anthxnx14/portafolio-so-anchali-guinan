# inventario.ps1 · Semana 1

# 1. Definimos el nombre del archivo de salida
$salida = "inventario_$env:COMPUTERNAME.txt"

# 2. Guardamos la información en variables usando los comandos
$cpu = Get-CimInstance Win32_Processor
$os = Get-CimInstance Win32_OperatingSystem
$ram = Get-CimInstance Win32_PhysicalMemory
$ip = Get-NetIPAddress -AddressFamily IPv4

# 3. Todo lo que esté dentro de las llaves { } se irá al archivo .txt
& {
    "== Equipo: $env:COMPUTERNAME | $(Get-Date)"
    "== SO: $($os.Caption) $($os.Version)"
    
    "== CPU"
    # Completamos las propiedades del CPU
    $cpu | Format-List Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed, L1CacheSize, L2CacheSize, L3CacheSize
    
    "== RAM"
    # Usamos el nuevo comando para la RAM
    $ram | Format-Table DeviceLocator, Capacity
    
    "== Discos"
    # Usamos Get-PhysicalDisk para mostrar Nombre (FriendlyName), Tipo (MediaType) y Tamaño (Size)
    Get-PhysicalDisk | Format-Table FriendlyName, MediaType, Size
    
    "== Interfaces de Red e IP"
    # Comando para el extra de la nota
    $ip | Format-Table InterfaceAlias, IPAddress

} | Out-File $salida

# 4. Mensaje que terminó
Write-Host "Reporte generado: $salida"
