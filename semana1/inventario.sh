#!/bin/bash
hostname > inventario_anchali-guinan.txt
date >> inventario_anchali-guinan.txt
cat /etc/os-release >> inventario_anchali-guinan.txt
lscpu >> inventario_anchali-guinan.txt
cat /proc/cpuinfo | grep "cpu MHz" | head -1 >> inventario_anchali-guinan.txt
free -h >> inventario_anchali-guinan.txt
lsblk >> inventario_anchali-guinan.txt
ip -br addr >> inventario_anchali-guinan.txt


