#!/usr/bin/env python
import time
import sys
import os
import shutil

from rgbmatrix import RGBMatrix, RGBMatrixOptions
from PIL import Image

# Configuration for the matrix
options = RGBMatrixOptions()
options.rows = 40
options.cols = 80
options.chain_length = 2
options.parallel = 1
options.gpio_slowdown = 4
#options.row_address_type = 0

options.hardware_mapping = 'regular'  # If you have an Adafruit HAT: 'adafruit-hat'
options.multiplexing = 1
options.brightness = 100
#options.pwm_lsb_nanoseconds = 300
#options.pwm_bits = 11

matrix = RGBMatrix(options = options)

#Bufer que se copia en la pantalla led
img_path='/srv/ledram/current.png'
#imagen por defecto a mostrar al inicializarla
init_file='/srv/init.png'

# Revisa si el bufer existe, si no existe lo crea
# y si existe sale ya que hay otro proceso que lo
if not os.path.isfile(img_path):
    shutil.copy(init_file, img_path)
    os.chmod(img_path, 0o666)
else:
    print("El archivo de buffer ya existe!")
    exit(1)

#guarda el tiempo de modificación
tstam = os.stat(img_path).st_mtime
matrix.SetImage(Image.open(img_path).convert('RGB'))

while True:
    time.sleep(0.1)
    ntstam  = os.stat(img_path).st_mtime
    #si el bufer fue modificado, lo carga en la pantalla led
    if ntstam > tstam:
        image=Image.open(img_path)
        matrix.SetImage(image.convert('RGB'))
        tstam = ntstam
