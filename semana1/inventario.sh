#!/bin/bash
echo "Iniciando inventario de hardware...."

echo "Obteniendo nombre del equipo"
hostname > inventario_anchali-guinan.txt

echo "La fecha actual es: "
date >> inventario_anchali-guinan.txt

echo "Sistema operativo..."
cat /etc/os-release >> inventario_anchali-guinan.txt

echo "Cargando información del procesador..."
lscpu >> inventario_anchali-guinan.txt

echo "Frecuencia del procesador..."
cat /proc/cpuinfo | grep "cpu MHz" | head -1 >> inventario_anchali-guinan.txt

echo "Cargando información de la memoria RAM..."
free -h >> inventario_anchali-guinan.txt

echo "Obteniendo informacion de los discos...."
lsblk >> inventario_anchali-guinan.txt

echo "Obteniendo interfaces de red...."
ip -br addr >> inventario_anchali-guinan.txt

echo "Inventario finalizado"
echo "Archivo generado sobre el inventario: inventario_anchali-guinan.txt"


