# Ayuda Memoria: Comandos de Administración OS (Linux y Windows)

## Linux (Bash)

El script `informe_arranque.sh` consulta el sistema operativo, la fecha de último arranque, el desglose de los tiempos de inicio (`systemd`), los servicios más lentos y los módulos del núcleo cargados.

### Cómo ejecutarlo
1. Abrir una terminal en la carpeta `semana03`.
2. Otorgar permisos de ejecución (solo la primera vez): `chmod +x informe_arranque.sh`
3. Ejecutar `./informe_arranque.sh`.
4. El informe queda guardado en un archivo `.txt` con el nombre del equipo y la marca de tiempo.

Funciona sin administrador (no requiere `sudo`). Si alguna herramienta como `systemd-analyze` no está disponible en el entorno (ej. en WSL), el script maneja el error internamente, muestra un aviso limpio en pantalla y continúa con la ejecución.

## Windows (PowerShell)

El script `informe_arranque.ps1` consulta el sistema operativo, el último arranque, los tiempos de inicio, los servicios, los controladores y el estado del inicio rápido.

### Cómo ejecutarlo
1. Abrir PowerShell en la carpeta `semana03`.
2. Ejecutar `.\informe_arranque.ps1`.
3. El informe queda guardado en un archivo `.txt` con el nombre del equipo y la fecha.

Funciona sin administrador. Si no tiene permiso para consultar el evento 100, muestra un aviso y continúa.
