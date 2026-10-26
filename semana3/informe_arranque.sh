#!/usr/bin/env bash
# =============================================================================
#  Deber 3 · Informe de arranque (Linux)             ESQUELETO PARA COMPLETAR
#  Sistemas Operativos · EPN · Semana 3
# -----------------------------------------------------------------------------
#  Autores:   <Anthony Anchali>, <Jonathan Guiñan>
#  Fecha:     <2026-10-25>
#  Uso de IA: <Sí, utilizado para depurar y corregir códigos.>
# -----------------------------------------------------------------------------
#  Qué debe hacer: reunir en un archivo de texto cómo arrancó esta máquina.
#    Secciones 1, 2 y 3  → las empiezan en el Taller 2 (parte D).
#    Secciones 4, 5 y 6  → las terminan en casa.
#  Uso:       chmod +x informe_arranque.sh && ./informe_arranque.sh
#             (no debe necesitar sudo)
#  Entrega:   guárdalo como semana03/informe_arranque.sh en el repositorio
#             de la pareja y súbelo a GitHub (instrucciones al final).
#
#  Cómo completar: reemplaza cada línea «echo "PENDIENTE ..."» por los comandos
#  que piden las pistas. Ejecuta el script después de cada sección.
# =============================================================================

set -u

EQUIPO="$(hostname -s 2>/dev/null || echo equipo)"
SALIDA="informe_arranque_${EQUIPO}_$(date +%Y%m%d_%H%M).txt"

titulo() {
    printf '\n=== %s ===\n' "$1"
}

tiene() {
    command -v "$1" >/dev/null 2>&1
}

# --- 1 · SO, versión y núcleo ------------------------- (Taller 2) ----------
seccion1() {
    titulo "1 · Sistema operativo, versión y núcleo"
    . /etc/os-release
    echo "Sistema: $PRETTY_NAME"
    echo "Núcleo: $(uname -r) ($(uname -m))"
}

# --- 2 · Último arranque y uptime --------------------- (Taller 2) ----------
seccion2() {
    titulo "2 · Último arranque y tiempo encendido"
    echo "Arrancó: $(uptime -s)"
    echo "Encendida: $(uptime -p)"
}

# --- 3 · Desglose del arranque ------------------------ (Taller 2) ----------
seccion3() {
    titulo "3 · Desglose del arranque (systemd-analyze)"
    if tiene systemd-analyze; then
        systemd-analyze time
    else
        echo "Aviso: El comando systemd-analyze no está disponible en este sistema."
    fi
}

# --- 4 · Cinco unidades más lentas -------------------- (en casa) -----------
seccion4() {
    titulo "4 · Las 5 unidades que más tardaron en arrancar"
    if tiene systemd-analyze; then
        systemd-analyze blame --no-pager | head -n 5
    else
        echo "Aviso: El comando systemd-analyze no está disponible en este sistema."
    fi
}

# --- 5 · Módulos del núcleo --------------------------- (en casa) -----------
seccion5() {
    titulo "5 · Módulos del núcleo cargados"
    # Cuenta todas las líneas de lsmod saltando la cabecera
    TOTAL=$(lsmod | tail -n +2 | wc -l)
    echo "Total de módulos cargados: $TOTAL"
    echo "Los 5 módulos más grandes:"
    # Ordena numéricamente en reversa por la segunda columna (tamaño)
    lsmod | tail -n +2 | sort -k2,2 -n -r | head -n 5
}

# --- 6 · Target por defecto y servicios fallidos ------ (en casa) -----------
seccion6() {
    titulo "6 · Target por defecto y servicios fallidos"
    echo "Target por defecto: $(systemctl get-default)"
    
    FALLIDOS=$(systemctl --failed --no-legend --plain)
    if [ -z "$FALLIDOS" ]; then
        echo "Servicios fallidos: ninguno"
    else
        echo "Servicios fallidos:"
        echo "$FALLIDOS"
    fi
}
{
    echo "Informe de arranque · $EQUIPO · $(date '+%Y-%m-%d %H:%M')"
    seccion1
    seccion2
    seccion3
    seccion4
    seccion5
    seccion6
} | tee "$SALIDA"

echo
echo "Informe guardado en: $SALIDA"

# -----------------------------------------------------------------------------
#  Subir al portafolio (GitHub), desde la carpeta del repositorio de la pareja:
#    git pull
#    git add semana03/informe_arranque.sh
#    git commit -m "Semana 3: informe de arranque (Linux), secciones 1-3"
#    git push
#  Haz un commit al terminar el taller y otro al terminar en casa.
#  Cada integrante hace al menos un commit con su parte (criterio de la rúbrica).
# -----------------------------------------------------------------------------
