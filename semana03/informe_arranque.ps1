# =============================================================================
#  Deber 3 · Informe de arranque (Windows)           ESQUELETO PARA COMPLETAR
#  Sistemas Operativos · EPN · Semana 3
# -----------------------------------------------------------------------------
# Autores: Anthony Anchali y Jonathan Guiñan
# Fecha: 2026-10-27
# Uso de IA: ChatGPT para entender los comandos,
# completar el script y revisar errores.
# -----------------------------------------------------------------------------
#  Qué debe hacer: reunir en un archivo de texto cómo arrancó esta máquina.
#    Secciones 1, 2 y 3  → las empiezan en el Taller 2 (parte D).
#    Secciones 4, 5 y 6  → las terminan en casa.
#  Uso:       .\informe_arranque.ps1
#             Si Windows bloquea el script, una sola vez:
#             Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#  Entrega:   guárdalo como semana03/informe_arranque.ps1 en el repositorio
#             de la pareja y súbelo a GitHub (instrucciones al final).
#
#  Cómo completar: reemplaza cada línea «"PENDIENTE ..."» por los comandos que
#  piden las pistas. Ejecuta el script después de cada sección.
# =============================================================================

$equipo = $env:COMPUTERNAME
$salida = "informe_arranque_{0}_{1}.txt" -f $equipo, (Get-Date -Format "yyyyMMdd_HHmm")
$power  = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power'
$logDiag = 'Microsoft-Windows-Diagnostics-Performance/Operational'

function Titulo([string]$texto) {
    ""
    "=== $texto ==="
}

# Devuelve $true si la PowerShell se abrió como administrador.
function EsAdministrador {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Lee un dato con nombre (por ejemplo 'BootTime') de un evento del registro.
function DatoEvento($evento, [string]$nombre) {
    $xml = [xml]$evento.ToXml()
    ($xml.Event.EventData.Data | Where-Object { $_.Name -eq $nombre }).'#text'
}

# --- 1 · SO, versión y compilación -------------------- (Taller 2) ----------
function Seccion1 {
    Titulo "1 · Sistema operativo, versión y compilación"
    # Pista: $os = Get-CimInstance Win32_OperatingSystem
    #        Usa $os.Caption, $os.Version, $os.BuildNumber y $os.OSArchitecture.
    # TODO
    try {
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
    "Sistema: $($os.Caption)"
    "Versión: $($os.Version)"
    "Compilación: $($os.BuildNumber)"
    "Arquitectura: $($os.OSArchitecture)"
} catch {
    "Aviso: no se pudo consultar el sistema operativo."
}
}

# --- 2 · Último arranque y uptime --------------------- (Taller 2) ----------
function Seccion2 {
    Titulo "2 · Último arranque y tiempo encendido"
    # Pista: $os.LastBootUpTime es la fecha del último arranque completo.
    #        (Get-Date) - $os.LastBootUpTime da el tiempo encendido; usa sus
    #        propiedades .Days, .Hours y .Minutes.
    # TODO
    try {
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
    $tiempo = (Get-Date) - $os.LastBootUpTime
    "Último arranque: $($os.LastBootUpTime)"
    "Tiempo encendido: $($tiempo.Days) días, $($tiempo.Hours) horas y $($tiempo.Minutes) minutos"
} catch {
    "Aviso: no se pudo consultar el último arranque."
}
}

# --- 3 · Desglose del arranque ------------------------ (Taller 2) ----------
function Seccion3 {
    Titulo "3 · Desglose del arranque"
    # Pista: el tiempo del firmware está en el registro:
    #        (Get-ItemProperty -Path $power -Name FwPOSTTime).FwPOSTTime  (ms)
    # Pista: el desglose del sistema es el evento 100 de $logDiag y necesita
    #        administrador. Si (EsAdministrador) es falso, muestra un aviso.
    #        $e = Get-WinEvent -FilterHashtable @{ LogName = $logDiag; Id = 100 } -MaxEvents 1
    #        DatoEvento $e 'BootTime' (también 'MainPathBootTime' y 'BootPostBootTime'), en ms.
    # TODO
    try {
    $fw = (Get-ItemProperty -Path $power -Name FwPOSTTime -ErrorAction Stop).FwPOSTTime
    "Firmware: {0} ms ({1:N3} s)" -f $fw, ($fw / 1000)
} catch {
    "Aviso: el tiempo del firmware no está disponible."
}

if (-not (EsAdministrador)) {
    "Aviso: se necesita administrador para consultar el evento 100. El informe continúa."
    return
}

try {
    $e = Get-WinEvent -FilterHashtable @{LogName=$logDiag; Id=100} -MaxEvents 1 -ErrorAction Stop
    "Fecha del último evento 100: $($e.TimeCreated)"

    foreach ($campo in 'MainPathBootTime','BootPostBootTime','BootTime') {
        $ms = DatoEvento $e $campo
        if ([string]::IsNullOrWhiteSpace($ms)) {
            throw "Falta el dato $campo."
        }
        "{0}: {1} ms ({2:N3} s)" -f $campo, $ms, ([double]$ms / 1000)
    }
} catch {
    "Aviso: no se pudo consultar el evento 100 o sus datos."
}
}

# --- 4 · Servicios y demoras -------------------------- (en casa) -----------
function Seccion4 {
    Titulo "4 · Servicios y demoras del arranque"
    try {
        $servicios = @(Get-CimInstance Win32_Service -ErrorAction Stop)
        $activos = @($servicios | Where-Object State -eq 'Running')
        $detenidos = @($servicios | Where-Object {
            $_.StartMode -eq 'Auto' -and $_.State -eq 'Stopped'
        } | Sort-Object Name)

        "Servicios en ejecución: $($activos.Count)"
        "Servicios automáticos detenidos: $($detenidos.Count)"
        "Hasta 5 servicios automáticos detenidos:"

        if ($detenidos.Count -eq 0) {
            "No se encontraron."
        } else {
            foreach ($servicio in ($detenidos | Select-Object -First 5)) {
                "- $($servicio.Name): $($servicio.DisplayName)"
            }
        }
        "Esta lista muestra estados; no mide tiempos de arranque."
    } catch {
        "Aviso: no se pudieron consultar los servicios."
    }
}

# --- 5 · Controladores -------------------------------- (en casa) -----------
function Seccion5 {
    Titulo "5 · Controladores (drivers)"
    # Pista: driverquery /fo csv | ConvertFrom-Csv  → cuenta los controladores.
    #        Get-CimInstance Win32_SystemDriver → cuenta los que están 'Running'.
    # TODO
   try {
    $datos = @(driverquery /fo csv 2>$null)
    if ($LASTEXITCODE -ne 0 -or $datos.Count -eq 0) {
        throw "No se obtuvo la lista de controladores."
    }
    $drivers = @($datos | ConvertFrom-Csv -ErrorAction Stop)
    "Controladores listados por driverquery: $($drivers.Count)"
} catch {
    "Aviso: driverquery no está disponible o no pudo obtener los datos."
}

try {
    $activos = @(Get-CimInstance Win32_SystemDriver -ErrorAction Stop |
        Where-Object State -eq 'Running')
    "Controladores en ejecución: $($activos.Count)"
} catch {
    "Aviso: no se pudieron consultar los controladores en ejecución."
}
}

# --- 6 · Inicio rápido -------------------------------- (en casa) -----------
function Seccion6 {
    Titulo "6 · Inicio rápido"
    # Pista: (Get-ItemProperty -Path $power -Name HiberbootEnabled).HiberbootEnabled
    #        vale 1 si el inicio rápido está activado y 0 si no.
    # TODO
    try {
    $inicio = (Get-ItemProperty -Path $power -Name HiberbootEnabled -ErrorAction Stop).HiberbootEnabled

    if ($inicio -eq 1) {
        "HiberbootEnabled = 1: inicio rápido activado."
    } elseif ($inicio -eq 0) {
        "HiberbootEnabled = 0: inicio rápido desactivado."
    } else {
        "Aviso: HiberbootEnabled no tiene un valor válido disponible."
    }
} catch {
    "Aviso: no se pudo consultar el estado del inicio rápido."
}
}

$informe = & {
    "Informe de arranque · $equipo · $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    Seccion1
    Seccion2
    Seccion3
    Seccion4
    Seccion5
    Seccion6
}
$informe | Set-Content -LiteralPath $salida -Encoding UTF8
$informe
""
"Informe guardado en: $salida"

# -----------------------------------------------------------------------------
#  Subir al portafolio (GitHub), desde la carpeta del repositorio de la pareja:
#    git pull
#    git add semana03/informe_arranque.ps1
#    git commit -m "Semana 3: informe de arranque (Windows), secciones 1-3"
#    git push
#  Haz un commit al terminar el taller y otro al terminar en casa.
#  Cada integrante hace al menos un commit con su parte (criterio de la rúbrica).
# -----------------------------------------------------------------------------
