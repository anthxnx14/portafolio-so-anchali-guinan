#!/usr/bin/env bash
# =============================================================================
#  Deber 5 · Auditoría de seguridad del equipo (Linux)    ESQUELETO PARA COMPLETAR
#  Sistemas Operativos · EPN · Semana 5
# -----------------------------------------------------------------------------
#  Autores:   <Anthony Anchali>, <Jonathan Guiñan>
#  Fecha:     <2026-11-18>
#  Uso de IA: <Sí, se usó para depurar y mejorar la legibilidad del código, pero no para generar la lógica principal de las secciones.>
# -----------------------------------------------------------------------------
#  Qué debe hacer: revisar cinco cosas del equipo y dar un veredicto.
#    1 · Llavero maestro   cuentas con UID 0 y miembros de wheel
#    2 · Puertas abiertas  servicios en escucha y puertas riesgosas a la red
#    3 · Portero activo    firewalld en marcha
#    4 · Intentos fallidos «Failed password» por IP (últimas 24 h o una muestra)
#    5 · Veredicto         ALERTA/OK por sección; código 0 (todo OK) o 1
#    Secciones 1 y 2  → en el Taller 2 (parte C).
#    Secciones 3, 4 y 5 → en casa.
#  Uso:       chmod +x auditoria_seguridad.sh
#             ./auditoria_seguridad.sh                     (bitácora real)
#             ./auditoria_seguridad.sh -m muestras_auth.log -u 5; echo $?
#             No debe necesitar sudo (tu usuario está en systemd-journal
#             gracias a preparar_vm_alma.sh).
#  Entrega:   semana05/auditoria_seguridad.sh en el repositorio de la pareja.
#
#  Cómo completar: reemplaza cada «echo "PENDIENTE ..."» por los comandos que
#  piden las pistas y marca la sección con «marca N OK» o «marca N ALERTA».
# =============================================================================

set -u
export LC_ALL=C

UMBRAL=5                 # fallos por IP a partir de los cuales hay ALERTA
MUESTRA=""               # si se indica (-m), la sección 4 lee este archivo
RIESGOSAS=(21 23 3306 3389 5900)   # puertas que no deberían dar a la red
declare -A ESTADO        # ESTADO[n]=OK|ALERTA  (lo llena «marca»)

while getopts "u:m:h" op; do
    case "$op" in
        u) UMBRAL="$OPTARG" ;;
        m) MUESTRA="$OPTARG" ;;
        *) echo "Uso: $0 [-u UMBRAL] [-m ARCHIVO_MUESTRA]"; exit 2 ;;
    esac
done

EQUIPO="$(hostname -s 2>/dev/null || echo equipo)"
SALIDA="auditoria_${EQUIPO}_$(date +%Y%m%d_%H%M).txt"
titulo() { printf '\n=== %s ===\n' "$1"; }
marca()  { ESTADO[$1]="$2"; printf '→ Sección %s: %s\n' "$1" "$2"; }

# --- 1 · Llavero maestro ------------------------------ (Taller 2) ----------
seccion1() {
    titulo "1 · Llavero maestro"
    local uid0 wheel_members extra_uid0

    uid0=$(awk -F: '$3==0 {print $1}' /etc/passwd)
    wheel_members=$(getent group wheel | cut -d: -f4)

    echo "Cuentas con UID 0:"
    echo "$uid0"
    echo "Miembros de wheel: ${wheel_members:-ninguno}"

    extra_uid0=$(printf '%s\n' "$uid0" | grep -vcx 'root')
    if [ "$extra_uid0" -gt 0 ]; then
        marca 1 ALERTA
    else
        marca 1 OK
    fi
}

# --- 2 · Puertas abiertas ----------------------------- (Taller 2) ----------
seccion2() {
    titulo "2 · Puertas abiertas"
    local direcciones d addr p alcance alerta=0 r

    direcciones=$(ss -H -tln | awk '{print $4}' | sort -u)

    for d in $direcciones; do
        p="${d##*:}"
        addr="${d%:*}"
        if [[ "$addr" == 127.* || "$addr" == "[::1]" ]]; then
            alcance="solo el equipo"
        else
            alcance="abierta a la red"
            for r in "${RIESGOSAS[@]}"; do
                if [ "$p" = "$r" ]; then
                    alerta=1
                fi
            done
        fi
        printf '  %-24s (puerto %-5s) → %s\n' "$d" "$p" "$alcance"
    done

    if [ "$alerta" -eq 1 ]; then
        marca 2 ALERTA
    else
        marca 2 OK
    fi
}

# --- 3 · Portero activo ------------------------------- (en casa) -----------
seccion3() {
    titulo "3 · Portero activo"
    local estado_fw zona_fw

    estado_fw=$(systemctl is-active firewalld 2>/dev/null || true)
    echo "Estado de firewalld: ${estado_fw:-inactivo}"

    if zona_fw=$(firewall-cmd --get-default-zone 2>/dev/null); then
        echo "Zona por defecto: $zona_fw"
    else
        echo "Zona por defecto: requiere sudo para consultar"
    fi

    if [ "$estado_fw" = "active" ]; then
        marca 3 OK
    else
        marca 3 ALERTA
    fi
}

# --- 4 · Intentos fallidos ---------------------------- (en casa) -----------
seccion4() {
    titulo "4 · Intentos fallidos (umbral: $UMBRAL por IP)"
    local registros conteo alerta=0 count ip

    if [ -n "$MUESTRA" ]; then
        if [ ! -r "$MUESTRA" ]; then
            echo "Error: no se puede leer el archivo de muestra '$MUESTRA'"
            marca 4 ALERTA
            return
        fi
        echo "Fuente: archivo de muestra ($MUESTRA)"
        registros=$(grep 'Failed password' "$MUESTRA" 2>/dev/null || true)
    else
        echo "Fuente: bitácora sshd (últimas 24 horas)"
        registros=$(journalctl -q -u sshd --since '24 hours ago' 2>/dev/null | grep 'Failed password' || true)
    fi

    if [ -z "$registros" ]; then
        echo "No se registraron intentos fallidos."
        marca 4 OK
        return
    fi

    conteo=$(printf '%s\n' "$registros" | awk '{for(i=1;i<=NF;i++) if($i=="from") print $(i+1)}' | sort | uniq -c | sort -rn)

    echo "Intentos por IP:"
    while read -r count ip; do
        [ -z "$count" ] && continue
        printf '  %-18s : %s intento(s)\n' "$ip" "$count"
        if [ "$count" -ge "$UMBRAL" ]; then
            alerta=1
        fi
    done <<< "$conteo"

    if [ "$alerta" -eq 1 ]; then
        marca 4 ALERTA
    else
        marca 4 OK
    fi
}

# --- 5 · Veredicto ------------------------------------ (en casa) -----------
seccion5() {
    titulo "5 · Veredicto"
    local n estado alertas=0

    for n in 1 2 3 4; do
        estado="${ESTADO[$n]:-SIN_DATOS}"
        printf '  Sección %s: %s\n' "$n" "$estado"
        if [ "$estado" = "ALERTA" ]; then
            alertas=$((alertas + 1))
        fi
    done

    echo "Total de alertas: $alertas"
    if [ "$alertas" -eq 0 ]; then
        echo "Veredicto final: OK (sin alertas de seguridad)"
        return 0
    else
        echo "Veredicto final: ALERTA (se requiere revisión)"
        return 1
    fi
}

principal() {
    echo "Auditoría de seguridad · $EQUIPO · $(date '+%Y-%m-%d %H:%M')"
    seccion1; seccion2; seccion3; seccion4; seccion5
}

# Las secciones se ejecutan en este mismo shell (para compartir ESTADO) y la
# salida se guarda también en un archivo.
exec > >(tee "$SALIDA")
principal
codigo=$?
echo
echo "Informe guardado en: $SALIDA"
exit "$codigo"

# -----------------------------------------------------------------------------
#  Subir al portafolio (GitHub), desde la carpeta del repositorio de la pareja:
#    git pull
#    git add semana05/auditoria_seguridad.sh semana05/auditoria_*.txt
#    git commit -m "Semana 5: auditoría de seguridad (Linux), secciones 1-2"
#    git push
#  Haz un commit al terminar el taller y otro al terminar en casa.
#  Cada integrante hace al menos un commit con su parte (criterio de la rúbrica).
# -----------------------------------------------------------------------------