
# Deber 2 - Memoria del sistema

**Integrantes:**
- Jonathan Guiñan
- Anthony Anchali

## Descripción

En esta carpeta se encuentran los scripts de la Semana 2, desarrollados para obtener información sobre la memoria y el almacenamiento del equipo.

Los scripts permiten consultar la arquitectura del procesador, el orden de bytes, las memorias caché, la memoria RAM y los discos. Además, calculan el número de conjuntos de la caché L1 de datos.

Los resultados se guardan en archivos de texto con el formato `memoria_<equipo>.txt`.

---

## Versión para Windows (PowerShell)

El archivo `memoria.ps1` contiene el script desarrollado para Windows. Permite consultar información sobre la memoria RAM, las memorias caché y los discos del equipo.

**Instrucciones de uso:**

1. Abrir una terminal de PowerShell.
2. Navegar hasta la carpeta `semana2/` del repositorio.
3. Si la ejecución de scripts está bloqueada, ejecutar el siguiente comando:

   `Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned`

4. Ejecutar el script:

   `.\memoria.ps1`

5. Visualizar el reporte generado:

   `Get-Content .\memoria_NOMBRE-EQUIPO.txt`

   Reemplazar `NOMBRE-EQUIPO` por el nombre correspondiente a la computadora.

## Versión para Linux (Bash)

El archivo `memoria.sh` permite obtener información sobre la memoria, el procesador y los discos del equipo.

**Instrucciones de uso:**

1. Abrir la terminal de Linux.
2. Entrar a la carpeta `semana2/`.
3. Dar permisos de ejecución:

   `chmod +x memoria.sh`

4. Ejecutar el script:

   `./memoria.sh`

5. Ver el reporte generado:

   `cat memoria_NOMBRE-EQUIPO.txt`