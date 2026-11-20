# Semana 5 · Auditoría de seguridad del equipo (Deber 5)

* **Asignatura:** Sistemas Operativos — EPN
* **Autores:** Jonathan Guiñan, Anthony Anchali
* **Fecha:** 2026-11-18

---

## Linux · `auditoria_seguridad.sh` (Jonathan Guiñan)

### Archivos
* `auditoria_seguridad.sh`: script en Bash que audita 5 controles de seguridad locales sin requerir `sudo`.
* `auditoria_localhost_20261118_1747.txt`: informe generado con la ejecución real en AlmaLinux.

### Qué revisa
1. **Llavero maestro:** cuentas con `UID 0` en `/etc/passwd` y miembros del grupo `wheel`.
2. **Puertas abiertas:** puertos TCP en escucha (`ss -H -tln`), diferenciando acceso local (`127.*`, `[::1]`) vs. expuesto a la red (`21, 23, 3306, 3389, 5900`).
3. **Portero activo:** estado del servicio `firewalld` y zona por defecto.
4. **Intentos fallidos:** eventos `Failed password` por IP en `journalctl -u sshd` (últimas 24 h) o desde archivo de muestra (`-m`).
5. **Veredicto:** resumen `OK`/`ALERTA` por sección con código de salida `0` (sin alertas) o `1` (con alertas).

### Ejecución
```bash
cd semana05
chmod +x auditoria_seguridad.sh

# Bitácora real del sistema
./auditoria_seguridad.sh; echo "Código: $?"

# Archivo de muestra
./auditoria_seguridad.sh -m ../muestras_auth.log -u 5; echo "Código: $?"


```

---

## Windows - Auditoría de seguridad

**Responsable:** Anthony Anchali

### Descripción

Se desarrolló un script en PowerShell que permite revisar cinco aspectos de seguridad: usuarios administradores, puertos abiertos, estado del firewall, intentos fallidos de autenticación y veredicto final.

### Archivos

- `auditoria_seguridad.ps1`: script de auditoría.
- `auditoria_DESKTOP-TGCDG8F_20261120_1409.txt`: informe generado.

### Ejecución

Ejecutar en PowerShell desde la carpeta semana05:

`.\auditoria_seguridad.ps1 -Muestra "C:\Users\Lenovo\Downloads\muestras_eventos_4625.csv" -Umbral 5`

### Resultados

| Sección | Estado |
|---|---|
| 1. Llavero maestro | OK |
| 2. Puertas abiertas | OK |
| 3. Portero activo | OK |
| 4. Intentos fallidos | ALERTA |
| 5. Veredicto final | ALERTA |

**Código de salida:** 1

La alerta se generó porque se detectaron 8 intentos fallidos desde la IP 45.83.1.20, superando el umbral de 5 intentos.

**Uso de IA:** Se utilizó ChatGPT como apoyo para desarrollar, revisar y depurar el script.


