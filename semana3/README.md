# Ayuda Memoria: Comandos de Administración OS (Linux)

Esta guía resume los comandos utilizados en el script `informe_arranque.sh` para extraer información del sistema operativo, el hardware, los tiempos de arranque y los módulos del núcleo en un entorno Linux.

## 1. Información del Sistema Operativo y Núcleo
Comandos para identificar la distribución de Linux instalada y la versión exacta del kernel.

*   `cat /etc/os-release`: Muestra información detallada sobre la distribución del sistema operativo (nombre, versión, ID). 
    *   *Ejemplo de uso:* `. /etc/os-release && echo $PRETTY_NAME` (Carga las variables del archivo para usarlas directamente).
*   `uname -r`: Muestra la versión exacta del núcleo (kernel) de Linux (ej. `6.12.0-211.7.3.el10_2.x86_64`).
*   `uname -m`: Muestra la arquitectura de hardware de la máquina (ej. `x86_64`).

## 2. Tiempo de Encendido y Último Arranque
Comandos para consultar cuánto tiempo lleva la máquina encendida de forma ininterrumpida.

*   `uptime -s`: Muestra la fecha y hora exacta (timestamp) en la que el sistema arrancó por última vez (ej. `2026-10-24 17:42:40`).
*   `uptime -p`: Muestra el tiempo total transcurrido desde el encendido en formato amigable (ej. `up 16 minutes`).

## 3. Análisis del Arranque (systemd)
Comandos del gestor de servicios `systemd` para diagnosticar el rendimiento del encendido.

*   `systemd-analyze` (o `systemd-analyze time`): Desglosa el tiempo total de arranque en sus fases principales: kernel, initrd y espacio de usuario (userspace).
*   `systemd-analyze blame`: Lista todos los servicios y unidades que se ejecutaron durante el arranque, ordenados desde el que más tardó hasta el que menos tardó.
    *   *Ejemplo de uso:* `systemd-analyze blame --no-pager | head -n 5` (Muestra solo los 5 servicios más lentos, sin paginación).
*   `systemd-analyze critical-chain`: Muestra el árbol de dependencias que retrasó el arranque (la "cadena crítica").

## 4. Gestión de Servicios
Comandos para verificar el estado de los servicios configurados en el sistema.

*   `systemctl get-default`: Muestra cuál es el "Target" predeterminado al que arranca el sistema (ej. `graphical.target` para interfaz gráfica, o `multi-user.target` para consola pura).
*   `systemctl --failed`: Lista todos los servicios o unidades que intentaron arrancar pero fallaron.
    *   *Ejemplo de uso:* `systemctl --failed --no-legend --plain` (Muestra una lista limpia, sin encabezados, ideal para scripts).

## 5. Módulos del Núcleo (Drivers)
Comandos para interactuar con los controladores cargados en la memoria del sistema.

*   `lsmod`: Muestra una lista de todos los módulos del núcleo actualmente cargados, junto con su tamaño y dependencias.
*   *Técnica de filtrado por tamaño:*
    *   `lsmod | tail -n +2`: Omite la primera línea (cabecera).
    *   `sort -k2,2 -n -r`: Ordena la lista numéricamente (`-n`), en reversa (`-r`), basándose exclusivamente en la segunda columna (`-k2,2`), que representa el tamaño del módulo.
    *   `wc -l`: Cuenta el número total de líneas (módulos cargados).

## 6. Utilidades de Scripting (Bash)
Herramientas útiles para automatizar tareas en la terminal.

*   `hostname -s`: Muestra el nombre corto de la computadora en la red.
*   `date +%Y%m%d_%H%M`: Genera una marca de tiempo con año, mes, día, hora y minuto (ej. `20261024_1759`).
*   `command -v <comando>`: Verifica de forma silenciosa si un comando o programa está instalado en el sistema antes de intentar ejecutarlo.
*   `tee <archivo>`: Lee de la entrada estándar y escribe simultáneamente en la pantalla (consola) y en el archivo especificado.