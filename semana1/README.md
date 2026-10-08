### Semana 1
# Deber 1 - Script de inventario de hardware

**Integrantes:**
- [Jonathan Guiñan]
- [Anthony Anchali]

## Descripción
En esta carpeta se encuentran los scripts de la Semana 01 desarrollados para automatizar la recolección de información de hardware (CPU, RAM, Discos, etc.). Los scripts generan un reporte y lo guardan en un archivo de texto con el formato `inventario_<equipo>.txt`.

---

##  Versión para Windows (PowerShell)
El archivo `inventario.ps1` contiene el script diseñado para ejecutarse en el SO Windows.

**Instrucciones de uso:**
1. Abrir una consola de PowerShell.
2. Navegar hasta la carpeta `semana1/`.
3. Ejecutar el script con el siguiente comando:
   ```powershell
   .\inventario.ps1

## Versión para Linux (Bash)
El archivo `inventario.sh` contiene el script diseñado para ejecutarse 
en el SO Linux.

**Instrucciones de uso:**

1. Abrir una terminal de Linux (Ubuntu o WSL).

2. Clonar el repositorio de GitHub mediante el siguiente comando:

   `git clone https://github.com/anthxnx14/portafolio-so-anchali-guinan.git`

3. Ingresar a la carpeta `semana1`:

   `cd portafolio-so-anchali-guinan/semana1`

4. Otorgar permisos de ejecución al script:

   `chmod +x inventario.sh`

5. Ejecutar el script:

   `./inventario.sh`

6. Visualizar el reporte generado:

   `cat inventario_anchali-guinan.txt`

**Archivo generado:**

El script genera el archivo `inventario_anchali-guinan.txt`, que contiene
información del sistema operativo, procesador, memoria RAM, discos e 
interfaces de red.
