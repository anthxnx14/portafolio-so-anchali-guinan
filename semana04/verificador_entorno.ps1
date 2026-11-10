# =============================================================================
#  Deber 4 · Verificador de entorno (Windows)            ESQUELETO PARA COMPLETAR
#  Sistemas Operativos · EPN · Semana 4
# -----------------------------------------------------------------------------
#  Autores:   <Anthony Anchali>, <Jonathan Guiñan>
#  Fecha:     <2026-11-10>
#  Uso de IA: <Sí, para depurar el codigo y generar pistas, pero no para escribirlo completo.>
# -----------------------------------------------------------------------------
#  Qué debe hacer: revisar si este equipo tiene las herramientas que usamos en
#  la materia, de dónde vienen y qué falta instalar. Termina con código de
#  salida 0 si está todo y 1 si falta algo.
#    Secciones 1, 2 y 3  → las empiezan en el Taller 2 (parte C).
#    Secciones 4, 5 y 6  → las terminan en casa.
#  Uso:       .\verificador_entorno.ps1
#             .\verificador_entorno.ps1; $LASTEXITCODE    (debe mostrar 0 o 1)
#             No necesita administrador: solo consulta.
#             Si Windows bloquea el script, una sola vez:
#             Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#  Entrega:   semana04/verificador_entorno.ps1 en el repositorio de la pareja
#             (instrucciones al final).
#
#  Cómo completar: reemplaza cada línea «"PENDIENTE ..."» por los comandos que
#  piden las pistas. Ejecuta el script después de cada sección.
# =============================================================================

$equipo = $env:COMPUTERNAME
$salida = "verificador_{0}_{1}.txt" -f $equipo, (Get-Date -Format "yyyyMMdd_HHmm")

# Herramientas que pide la materia (comando → identificador de winget).
# Ojo: en Windows PowerShell 5.1, «curl» es un alias de Invoke-WebRequest;
# el programa real es curl.exe.
$requeridas = [ordered]@{
    'git'      = 'Git.Git'
    'curl.exe' = 'cURL.cURL'
    'python'   = 'Python.Python.3.12'
    'jq'       = 'jqlang.jq'
    'winget'   = 'Microsoft.AppInstaller (desde Microsoft Store)'
}
$script:faltan = @()      # la sección 2 agrega aquí lo que no encuentre

function Titulo([string]$texto) { ""; "=== $texto ===" }

# Busca un programa real (no alias ni función) y descarta el atajo de la Store
# que abre la tienda en lugar de ejecutar Python.
function Buscar([string]$nombre) {
    $c = Get-Command $nombre -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($c -and $c.Source -like '*\WindowsApps\python*.exe' -and (Get-Item $c.Source).Length -eq 0) { return $null }
    $c
}

# Programas instalados según el registro (lo que muestra «Aplicaciones instaladas»).
function ProgramasInstalados {
    $claves = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
              'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
              'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    Get-ItemProperty $claves -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName }
}

# --- 1 · Sistema y shell ------------------------------- (Taller 2) ----------
function Seccion1 {
    Titulo "1 · Sistema y shell"
    # Pista: $os = Get-CimInstance Win32_OperatingSystem  → $os.Caption, $os.BuildNumber
    # Pista: $PSVersionTable.PSVersion y $PSVersionTable.PSEdition; usuario: $env:USERNAME
    # TODO
    $os = Get-CimInstance Win32_OperatingSystem
    "Sistema: $($os.Caption) (Build $($os.BuildNumber))"
    "Versión de PowerShell: $($PSVersionTable.PSVersion) ($($PSVersionTable.PSEdition))"
    "Usuario actual: $env:USERNAME"
}

# --- 2 · Herramientas requeridas ----------------------- (Taller 2) ----------
function Seccion2 {
    Titulo "2 · Herramientas requeridas"
    # Pista: foreach ($nombre in $requeridas.Keys) { $c = Buscar $nombre ... }
    #        Si $c existe, devuelve un objeto:
    #        [pscustomobject]@{ Comando = $nombre; Estado = 'OK'; Ruta = $c.Source;
    #                           Version = (& $c.Source --version 2>&1 | Select-Object -First 1) }
    #        Si no, Estado = 'FALTA' y agrégalo:  $script:faltan += $nombre
    # TODO
    foreach ($nombre in $requeridas.Keys) {
    $c = Buscar $nombre
    if ($c) {
        [pscustomobject]@{ 
            Comando = $nombre; 
            Estado = 'OK'; 
            Ruta = $c.Source;
            Version = (& $c.Source --version 2>&1 | Select-Object -First 1) 
        }
    } else {
        $script:faltan += $nombre
        [pscustomobject]@{ 
            Comando = $nombre; 
            Estado = 'FALTA'; 
            Ruta = 'N/A';
            Version = 'N/A' 
        }
    }
}
}

# --- 3 · Paquetes instalados y repositorios ------------ (Taller 2) ----------
function Seccion3 {
    Titulo "3 · Programas instalados y orígenes de winget"
    # Pista: (ProgramasInstalados | Measure-Object).Count  cuenta los programas.
    # Pista: si (Buscar 'winget') existe, «winget source list» muestra los orígenes
    #        (los repositorios de winget). Si no existe, Write-Warning.
    # TODO
    $cantidad = (ProgramasInstalados | Measure-Object).Count
"Total de programas instalados: $cantidad"

if (Buscar 'winget') {
    "Orígenes de winget configurados:"
    winget source list
} else {
    Write-Warning "winget no está instalado en este equipo."
}
}

# --- 4 · Últimas 5 instalaciones ----------------------- (en casa) -----------
function Seccion4 {
    Titulo "4 · Últimas 5 instalaciones"
    ProgramasInstalados | Where-Object { $_.InstallDate } |
        Sort-Object InstallDate -Descending | 
        Select-Object -First 5 InstallDate, DisplayName, DisplayVersion
}

# --- 5 · Qué falta y cómo instalarlo ------------------- (en casa) -----------
function Seccion5 {
    Titulo "5 · Qué falta y cómo instalarlo"
    if ($script:faltan.Count -eq 0) {
        "No falta nada."
    } else {
        "Comando rápido para instalar lo que falta:"
        $paquetesWinget = $script:faltan | ForEach-Object { $requeridas[$_] }
        "winget install --id $($paquetesWinget -join ' ') -e"
    }
}

# --- 6 · Resultado ------------------------------------- (en casa) -----------
function Seccion6 {
    Titulo "6 · Resultado"
    $listas = $requeridas.Count - $script:faltan.Count
    "Herramientas listas: $listas de $($requeridas.Count)"
}

# Format-Table | Out-String convierte los objetos en texto para el informe.
$informe = & {
    "Verificador de entorno · $equipo · $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    Seccion1
    Seccion2 | Format-Table -AutoSize | Out-String -Width 200
    Seccion3
    Seccion4 | Format-Table -AutoSize | Out-String -Width 200
    Seccion5
    Seccion6
}
$informe | Out-File -FilePath $salida -Encoding utf8; Get-Content $salida
""
"Informe guardado en: $salida"
# Pista (sección 6): cambia la línea siguiente para salir con 1 si falta algo.
exit 0

# -----------------------------------------------------------------------------
#  Subir al portafolio (GitHub), desde la carpeta del repositorio de la pareja:
#    git pull
#    git add semana04/verificador_entorno.ps1 semana04/verificador_*.txt
#    git commit -m "Semana 4: verificador de entorno (Windows), secciones 1-3"
#    git push
#  Haz un commit al terminar el taller y otro al terminar en casa.
#  Cada integrante hace al menos un commit con su parte (criterio de la rúbrica).
# -----------------------------------------------------------------------------
