# Semana 4: Verificador de Entorno 

Este directorio contiene los scripts desarrollados para el **Deber 4** de la materia Sistemas Operativos. El objetivo de estas herramientas es auditar un sistema operativo (Linux o Windows) para verificar la disponibilidad de las herramientas requeridas para el curso, listar los programas instalados y generar un reporte automático.

**Autores:**
* Anthony Anchali (Entorno Linux / Bash)
* Jonathan Guiñan (Entorno Windows / PowerShell)

---

##  Archivos del proyecto

* `verificador_entorno.sh`: Script de auditoría para sistemas Linux (AlmaLinux/Ubuntu).
* `verificador_entorno.ps1`: Script de auditoría para sistemas Windows.
* `verificador_<equipo>_<fecha>.txt`: Reportes generados automáticamente tras la ejecución de los scripts.

---

##  Cómo utilizar los scripts

Los scripts no requieren permisos de administrador (root/elevados) para ejecutarse, ya que solo realizan consultas al sistema.

### En Windows (PowerShell)
1. Abre una terminal de PowerShell.
2. Si es la primera vez que se ejecutan scripts locales en el equipo, habilitar la ejecución de scripts (solo es necesario hacerlo una vez):
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned


   ```

3. Ejecutar el verificador:

   ```powershell
   .\verificador_entorno.ps1
   $LASTEXITCODE
   ```

### En Linux (Bash)

1. Abrir la terminal de Linux.
2. Entrar a la carpeta `semana04`.
3. Ejecutar los siguientes comandos:

   ```bash
   chmod +x verificador_entorno.sh
   ./verificador_entorno.sh
   echo "Código de salida: $?"
   ```

El programa genera automáticamente un informe `.txt` con los resultados.

---

## Pruebas realizadas en Linux

El script fue ejecutado en Ubuntu 24.04.5 LTS mediante WSL2, utilizando Bash 5.2.21.

Aunque la guía solicita AlmaLinux, el código fue adaptado para trabajar con `apt/dpkg` en Ubuntu y `dnf/rpm` en AlmaLinux.

### Resultados obtenidos

- Paquetes instalados: 529.
- Herramientas verificadas: 6.
- Herramientas disponibles: 6 de 6.
- Herramientas faltantes: ninguna.
- Código de salida: 0.
- Estado final: OK.

Se verificaron las herramientas `git`, `curl`, `python3`, `jq`, `strace` y `tree`.

También se comprobó que, cuando faltaba `tree`, el verificador devolvía el código 1 y mostraba el comando necesario para instalarlo.

### Compatibilidad

El script funciona correctamente en Ubuntu WSL2. La compatibilidad con AlmaLinux está implementada, pero no se ha comprobado directamente en esa distribución.

## Uso de inteligencia artificial

Se utilizó ChatGPT para guiar, generar parte del código, explicar, y revisar las seis secciones del script Bash, así como para implementar la compatibilidad entre Ubuntu y AlmaLinux.

Los resultados presentados fueron obtenidos mediante la ejecución del programa.
