# =============================================================================
#  Deber 5 · Auditoría de seguridad del equipo (Windows)  ESQUELETO PARA COMPLETAR
#  Sistemas Operativos · EPN · Semana 5
# -----------------------------------------------------------------------------
#  Autores:   Anthony Anchali, Jonathan Guiñan
#  Fecha:     2026-11-20
#  Uso de IA: ChatGPT como apoyo para desarrollar,
#             revisar y explicar los comandos del script.
# -----------------------------------------------------------------------------
#  Qué debe hacer: revisar cinco cosas del equipo y dar un veredicto.
#    1 · Llavero maestro   miembros de Administradores (S-1-5-32-544) y la
#                          cuenta Administrador integrada (SID ...-500)
#    2 · Puertas abiertas  servicios en escucha y puertas riesgosas a la red
#    3 · Portero activo    perfiles de Windows Firewall habilitados
#    4 · Intentos fallidos eventos 4625 por IP (últimas 24 h o una muestra)
#    5 · Veredicto         ALERTA/OK por sección; código 0 (todo OK) o 1
#    Secciones 1 y 2  → en el Taller 2 (parte C).
#    Secciones 3, 4 y 5 → en casa.
#  Uso:       .\auditoria_seguridad.ps1 -Muestra .\muestras_eventos_4625.csv -Umbral 5
#             .\auditoria_seguridad.ps1 -Muestra .\muestras_eventos_4625.csv; $LASTEXITCODE
#             Sin administrador, la sección 4 usa -Muestra (el registro de
#             Seguridad solo lo lee un administrador).
#             Si Windows bloquea el script, una sola vez:
#             Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
#  Entrega:   semana05/auditoria_seguridad.ps1 en el repositorio de la pareja.
#
#  Cómo completar: reemplaza cada línea «"PENDIENTE ..."» por los comandos que
#  piden las pistas y marca la sección con  Marca N "OK"  o  Marca N "ALERTA".
# =============================================================================
param(
    [ValidateRange(1,2147483647)]
    [int]$Umbral = 5,
    [string]$Muestra = ""
)

$riesgosas = @(21,23,3306,3389,5900)
$estado = [ordered]@{}
$equipo = $env:COMPUTERNAME
$salida = "auditoria_{0}_{1}.txt" -f $equipo, (Get-Date -Format "yyyyMMdd_HHmm")
$script:codigo = 0

function Titulo([string]$t) {
    ""
    "=== $t ==="
}

function Marca([int]$n, [string]$v) {
    $script:estado["$n"] = $v
    "Seccion ${n}: $v"
}

# ============================================================
# SECCION 1 - LLAVERO MAESTRO
# ALERTA si Administrador integrado esta habilitado.
# ============================================================

function Seccion1 {
    Titulo "1 - Llavero maestro"

    try {
        $miembros = @(Get-LocalGroupMember -SID 'S-1-5-32-544' -ErrorAction Stop)

        "Miembros de Administradores:"
        foreach ($m in $miembros) {
            " - $($m.Name)"
        }

        $admin = Get-LocalUser -ErrorAction Stop |
            Where-Object { $_.SID.Value -like '*-500' } |
            Select-Object -First 1

        if ($null -eq $admin) {
            "No se encontro la cuenta integrada."
            Marca 1 "ALERTA"
        }
        elseif ($admin.Enabled) {
            "La cuenta Administrador integrada esta habilitada."
            Marca 1 "ALERTA"
        }
        else {
            "La cuenta Administrador integrada esta deshabilitada."
            Marca 1 "OK"
        }
    }
    catch {
        "Error al revisar administradores: $($_.Exception.Message)"
        Marca 1 "ALERTA"
    }
}

# ============================================================
# SECCION 2 - PUERTAS ABIERTAS
# ALERTA si un puerto riesgoso escucha hacia la red.
# ============================================================

function Seccion2 {
    Titulo "2 - Puertas abiertas"

    try {
        $conexiones = @(
            Get-NetTCPConnection -State Listen -ErrorAction Stop |
            Sort-Object LocalPort, LocalAddress -Unique
        )

        "Puertos TCP en escucha: $($conexiones.Count)"

        $detectados = @(
            $conexiones | Where-Object {
                $_.LocalPort -in $riesgosas -and
                $_.LocalAddress -notin @('127.0.0.1','::1')
            }
        )

        if ($detectados.Count -gt 0) {
            "Puertos riesgosos expuestos:"

            foreach ($p in $detectados) {
                " - $($p.LocalAddress):$($p.LocalPort)"
            }

            Marca 2 "ALERTA"
        }
        else {
            "No existen puertos riesgosos abiertos a la red."
            Marca 2 "OK"
        }
    }
    catch {
        "Error al consultar puertos: $($_.Exception.Message)"
        Marca 2 "ALERTA"
    }
}

# ============================================================
# SECCION 3 - PORTERO ACTIVO
# ALERTA si algun perfil del Firewall esta deshabilitado.
# ============================================================

function Seccion3 {
    Titulo "3 - Portero activo"

    try {
        $perfiles = @(Get-NetFirewallProfile -ErrorAction Stop)

        "Perfiles de Windows Firewall:"

        foreach ($p in $perfiles) {
            " - $($p.Name): Enabled=$($p.Enabled)"
        }

        $deshabilitados = @(
            $perfiles | Where-Object { -not $_.Enabled }
        )

        if ($perfiles.Count -eq 0 -or $deshabilitados.Count -gt 0) {
            "Hay perfiles deshabilitados o no disponibles."
            Marca 3 "ALERTA"
        }
        else {
            "Todos los perfiles estan habilitados."
            Marca 3 "OK"
        }
    }
    catch {
        "Error al consultar firewall: $($_.Exception.Message)"
        Marca 3 "ALERTA"
    }
}

# ============================================================
# SECCION 4 - INTENTOS FALLIDOS
# Analiza archivo CSV o eventos 4625 de las ultimas 24 h.
# ALERTA si alguna IP alcanza el umbral.
# ============================================================

function Seccion4 {
    Titulo "4 - Intentos fallidos (umbral: $Umbral por IP)"

    try {
        $registros = @()

        if ($Muestra -ne "") {

            if (-not (Test-Path -LiteralPath $Muestra -PathType Leaf)) {
                throw "No se encontro la muestra: $Muestra"
            }

            "Origen: archivo de muestra"

            $registros = @(
                Import-Csv -LiteralPath $Muestra -ErrorAction Stop |
                Where-Object { $_.Id -eq '4625' } |
                Select-Object IpAddress
            )
        }
        else {
            "Origen: registro Security (ultimas 24 horas)"

            try {
                $eventos = @(
                    Get-WinEvent -FilterHashtable @{
                        LogName = 'Security'
                        Id = 4625
                        StartTime = (Get-Date).AddHours(-24)
                    } -ErrorAction Stop
                )
            }
            catch {
                if ($_.FullyQualifiedErrorId -match 'NoMatchingEventsFound') {
                    $eventos = @()
                }
                else {
                    throw
                }
            }

            $registros = @(
                foreach ($evento in $eventos) {

                    $xml = [xml]$evento.ToXml()

                    $dato = $xml.Event.EventData.Data |
                        Where-Object { $_.Name -eq 'IpAddress' } |
                        Select-Object -First 1

                    $ip = if ($null -ne $dato) {
                        [string]$dato.'#text'
                    }
                    else {
                        "-"
                    }

                    if ([string]::IsNullOrWhiteSpace($ip)) {
                        $ip = "-"
                    }

                    [PSCustomObject]@{
                        IpAddress = $ip
                    }
                }
            )
        }

        "Total de eventos 4625: $($registros.Count)"

        $grupos = @(
            $registros |
            Group-Object IpAddress |
            Sort-Object Count -Descending
        )

        "Intentos fallidos por IP:"

        foreach ($g in $grupos) {
            " - $($g.Name): $($g.Count)"
        }

        $sospechosas = @(
            $grupos | Where-Object { $_.Count -ge $Umbral }
        )

        if ($sospechosas.Count -gt 0) {
            "Se detectaron IP que alcanzaron el umbral."
            Marca 4 "ALERTA"
        }
        else {
            "Ninguna IP alcanzo el umbral."
            Marca 4 "OK"
        }
    }
    catch {
        "No fue posible completar la auditoria: $($_.Exception.Message)"
        "Si no tienes permisos, utiliza -Muestra con el CSV."
        Marca 4 "ALERTA"
    }
}

# ============================================================
# SECCION 5 - VEREDICTO FINAL
# Codigo 0 si todo esta OK, codigo 1 si existe ALERTA.
# ============================================================

function Seccion5 {
    Titulo "5 - Veredicto final"

    $numeroAlertas = 0

    foreach ($n in 1..4) {

        $resultado = $script:estado["$n"]

        if ([string]::IsNullOrEmpty($resultado)) {
            $resultado = "ALERTA"
        }

        "Seccion ${n}: $resultado"

        if ($resultado -ne "OK") {
            $numeroAlertas++
        }
    }

    if ($numeroAlertas -gt 0) {
        "VEREDICTO: ALERTA"
        "Se encontraron $numeroAlertas secciones que requieren revision."
        $script:codigo = 1
    }
    else {
        "VEREDICTO: OK"
        "No se detectaron alertas segun las reglas evaluadas."
        $script:codigo = 0
    }

    "Codigo de salida: $script:codigo"
}

# ============================================================
# EJECUCION Y GENERACION DEL INFORME
# ============================================================

& {
    "Auditoria de seguridad - $equipo"
    "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

    Seccion1
    Seccion2
    Seccion3
    Seccion4
    Seccion5

} | Tee-Object -FilePath $salida

""
"Informe guardado en: $salida"

exit $script:codigo

# -----------------------------------------------------------------------------
#  Subir al portafolio (GitHub), desde la carpeta del repositorio de la pareja:
#    git pull
#    git add semana05/auditoria_seguridad.ps1 semana05/auditoria_*.txt
#    git commit -m "Semana 5: auditoría de seguridad (Windows), secciones 1-2"
#    git push
#  Haz un commit al terminar el taller y otro al terminar en casa.
#  Cada integrante hace al menos un commit con su parte (criterio de la rúbrica).
# -----------------------------------------------------------------------------
