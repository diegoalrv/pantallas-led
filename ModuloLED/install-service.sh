#!/bin/bash

if [ "$EUID" -ne 0 ]; then
   echo "Este script requiere permisos de root."
   exit
fi

# set pwd to current directory
cd "$(dirname "$0")"

#limpia el contenido del directorio de trabajo
rm -rf /srv/ledram/*
rm -rf /srv/*

# Configura un directorio `/srv/ledram` como buffer de video
sed -i -e '/srv/d' /etc/fstab
sed -i -e '$a/tmpfs  /srv/ledram  tmpfs  rw,nosuid,nodev,size=32m   0  0' /etc/fstab

# Crea directorio donde se almacena el buffer de video
mkdir /srv/ledram

# Desocupa el tercer procesador para ser usado exclusivamente por el sub-proceso de renderizado
sed -i -e 's/ isocpus=3//g' /boot/cmdline.txt
sed -i -e 's/$/ isocpus=3/' /boot/cmdline.txt

#copia la biblioteca al directorio de trabajo
cp -R rgbmatrix /srv/rgbmatrix

#copia el sub-sistema de renderizado
mkdir /srv/subsystem
cp -rf init.png /srv
cp -rf led-driver.py /srv/subsystem

#Crea el servicio
cp -rf led-driver.service /etc/systemd/system/led-driver.service

# Recarga e inicia automaticamente al prender.
systemctl daemon-reload
systemctl unmask led-driver.service
systemctl enable led-driver.service

# Mensajes de salida
echo "Debe reiniciar la Raspberry para que el servicio pueda iniciarse"
echo "Luego para actualizar, solo debe modificar el el archivo '/srv/ledram/current.png' para actualizar la pantalla"
