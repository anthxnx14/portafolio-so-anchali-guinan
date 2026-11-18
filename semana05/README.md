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