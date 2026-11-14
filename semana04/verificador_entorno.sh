#!/usr/bin/env bash

# =============================================================================
# Deber 4 - Verificador de entorno (Linux)
# Sistemas Operativos - EPN - Semana 4
# Autores: Anthony Anchali y Jonathan Guiñan
# Fecha: 13/11/2026
# Uso de IA: Si. Hicimos uso de ChatGPT para enseñar, corregir, adaptar y revisar las
# secciones 1 a 6 de Bash, incluida la compatibilidad con Ubuntu y AlmaLinux.
# Los resultados del informe se obtienen al ejecutar el script en cada equipo.
# =============================================================================
# Objetivo: consultar sistema, herramientas y paquetes SIN utilizar sudo.
# Resultado: codigo 0 si estan todas las herramientas;
# codigo 1 si falta alguna.

set -u
export LC_ALL=C

EQUIPO="$(hostname -s 2>/dev/null || printf 'equipo')"
SALIDA="verificador_${EQUIPO}_$(date +%Y%m%d_%H%M).txt"

REQUERIDAS=(git curl python3 jq strace tree)

declare -A PAQUETE=(
    [git]=git
    [curl]=curl
    [python3]=python3
    [jq]=jq
    [strace]=strace
    [tree]=tree
)

FALTAN=()

titulo() {
    printf '\n=== %s ===\n' "$1"
}

tiene() {
    command -v "$1" >/dev/null 2>&1
}

aviso() {
    printf 'AVISO: %s\n' "$*" >&2
}

# --- 1. SISTEMA Y SHELL --------------------------------

seccion1() {
    titulo '1 - Sistema y shell'

    if [[ -r /etc/os-release ]]; then
        . /etc/os-release
        printf 'Sistema operativo: %s\n' "${PRETTY_NAME:-Linux}"
    else
        printf 'Sistema operativo: Linux\n'
    fi

    printf 'Version del kernel: %s\n' "$(uname -r)"
    printf 'Version de Bash: %s\n' "$BASH_VERSION"
    printf 'Usuario actual: %s\n' "$(id -un)"
}

# --- 2. HERRAMIENTAS REQUERIDAS -------------------------

seccion2() {
    titulo '2 - Herramientas requeridas'

    printf '%-10s %-8s %-25s %s\n' \
        'Comando' 'Estado' 'Ruta' 'Version'

    local c ruta version

    for c in "${REQUERIDAS[@]}"; do

        if tiene "$c"; then

            ruta="$(command -v "$c")"

            if [[ "$c" == strace ]]; then
                version="$(strace -V 2>&1 | head -n 1)"
            else
                version="$("$c" --version 2>&1 | head -n 1)"
            fi

            printf '%-10s %-8s %-25s %s\n' \
                "$c" 'OK' "$ruta" "${version:-No disponible}"

        else

            FALTAN+=("$c")

            printf '%-10s %-8s %-25s %s\n' \
                "$c" 'FALTA' '-' '-'

        fi

    done
}

# --- 3. PAQUETES INSTALADOS Y REPOSITORIOS -------------

seccion3() {
    titulo '3 - Paquetes instalados y repositorios'

    if tiene dnf && tiene rpm; then

        # AlmaLinux utiliza dnf y rpm.

        printf 'Gestor de paquetes: dnf/rpm (AlmaLinux)\n'

        printf 'Paquetes instalados: %s\n' \
            "$(rpm -qa | wc -l)"

        printf 'Repositorios habilitados:\n'

        dnf -q -C repolist --enabled ||
            aviso 'No hay metadatos de dnf en cache.'

        if tiene jq; then

            printf 'Paquete propietario de jq: '

            rpm -qf "$(command -v jq)" || true

            printf 'Repositorio de jq:\n'

            dnf -q -C info --installed jq 2>/dev/null |
                grep -iE '^(From repo|Repository)[[:space:]]*:' ||
                aviso 'Origen de jq no disponible en cache.'

        fi

    elif tiene dpkg-query && tiene apt-cache; then

        # Ubuntu utiliza apt y dpkg.

        printf 'Gestor de paquetes: apt/dpkg (Ubuntu)\n'

        printf 'Paquetes instalados: %s\n' \
            "$(dpkg-query -W -f='${Status}\n' 2>/dev/null |
                grep -c '^install ok installed$')"

        printf 'Repositorios configurados:\n'

        apt-cache policy | head -n 17

        if tiene jq; then

            printf 'Paquete propietario de jq:\n'

            dpkg-query -S "$(command -v jq)" || true

            printf 'Origen y version de jq:\n'

            apt-cache policy jq | head -n 14

        fi

    else
        aviso 'No se encontro un gestor compatible.'
    fi
}

# --- 4. ULTIMAS 5 INSTALACIONES ------------------------

seccion4() {
    titulo '4 - Ultimas 5 transacciones de paquetes'

    if tiene dnf; then

        # Historial de AlmaLinux.

        dnf -q history list | head -n 7 ||
            aviso 'No se pudo consultar el historial de dnf.'

    elif tiene apt-cache; then

        # Historial de instalaciones en Ubuntu.

        local ultimas

        ultimas="$(
            { zcat -f /var/log/apt/history.log* 2>/dev/null || true; } |
            awk 'BEGIN {RS=""; FS="\n"}
                {
                    fecha=""
                    paquetes=""
                    comando=""

                    for(i=1;i<=NF;i++) {
                        if ($i ~ /^Start-Date: /)
                            fecha=substr($i,13)

                        if ($i ~ /^Commandline: /)
                            comando=substr($i,14)

                        if ($i ~ /^Install: /)
                            paquetes=substr($i,10)
                    }

                    if (fecha != "" && paquetes != "") {
                        print fecha " | " substr(comando,1,60) " | " \
                        substr(paquetes,1,100)
                    }
                }' | sort -r | head -n 5
        )"

        if [[ -n "$ultimas" ]]; then

            printf 'Fecha | Comando | Paquetes\n%s\n' "$ultimas"

        else

            aviso 'No se encontraron instalaciones recientes.'

        fi

    else

        aviso 'No esta disponible dnf ni apt.'

    fi
}

# --- 5. QUE FALTA Y COMO INSTALARLO --------------------

seccion5() {
    titulo '5 - Que falta y como instalarlo'

    if (( ${#FALTAN[@]} == 0 )); then

        printf 'No falta nada.\n'

    else

        local c
        local paquetes=()

        for c in "${FALTAN[@]}"; do
            paquetes+=("${PAQUETE[$c]}")
        done

        printf 'Faltan: %s\n' "${FALTAN[*]}"

        if tiene dnf; then

            printf 'Comando sugerido: sudo dnf install -y %s\n' \
                "${paquetes[*]}"

        elif tiene apt-cache; then

            printf 'Comando sugerido: sudo apt install -y %s\n' \
                "${paquetes[*]}"

        else

            aviso "No se reconoce el gestor de paquetes."

        fi
    fi
}

# --- 6. RESULTADO FINAL --------------------------------

seccion6() {
    titulo '6 - Resultado'

    local total=${#REQUERIDAS[@]}
    local listas=$((total - ${#FALTAN[@]}))

    printf 'Herramientas listas: %s de %s\n' \
        "$listas" "$total"

    if (( ${#FALTAN[@]} == 0 )); then

        printf 'Estado final: OK\n'
        return 0

    else

        printf 'Estado final: FALTAN HERRAMIENTAS\n'
        return 1

    fi
}

# --- FUNCION PRINCIPAL ---------------------------------

principal() {

    printf 'Verificador de entorno - %s - %s\n' \
        "$EQUIPO" "$(date '+%Y-%m-%d %H:%M')"

    seccion1
    seccion2
    seccion3
    seccion4
    seccion5
    seccion6
}

# --- GENERAR INFORME Y CODIGO DE SALIDA ----------------

principal 2>&1 | tee "$SALIDA"

codigo=${PIPESTATUS[0]}

printf '\nInforme guardado en: %s\n' "$SALIDA"

exit "$codigo"
