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