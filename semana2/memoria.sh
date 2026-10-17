#!/usr/bin/env bash
# memoria.sh - Deber 2, semana 2
salida="memoria_$(hostname).txt"
{
  echo "== Equipo: $(hostname) $(date +%F)"
  echo "== Arquitectura: $(uname -m)"
  lscpu | grep 'Byte Order'
  echo "== Cachés"; lscpu --caches
  echo "== RAM y swap"; free -h
  
  # TODO resuelto: discos -> lsblk -d -o NAME,ROTA,SIZE
  echo "== Discos"
  lsblk -d -o NAME,ROTA,SIZE
  
  # TODO resuelto: conjuntos L1d = C / (L * A)
  echo "== Conjuntos L1d =="
  C=$(getconf LEVEL1_DCACHE_SIZE)
  L=$(getconf LEVEL1_DCACHE_LINESIZE)
  A=$(getconf LEVEL1_DCACHE_ASSOC)
  S=$(( C / (L * A) ))
  echo "S = C / (L * A)"
  echo "S = $C / ($L * $A) = $S conjuntos"
  
} > "$salida"
echo "Reporte: $salida"