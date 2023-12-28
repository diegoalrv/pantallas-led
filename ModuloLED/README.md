# Guía de configuración para Modulo LED

## Materiales Necesarios

- Raspberry Pi, versión 3 o superior.
- Hat de conexión HUB75
- Paneles LED P4 con I/O HUB75
- Fuente de alimentación con salida 5V/3A
- Cables de Alimentación 4-pin 5V/3A
- Cables de datos con conexión HUB75

## Configuración inicial

### Conexionado

Para las conexiones de datos, se utilizan cables hembra HUB75 de 16-pines, estos se conectan en un extremo al HAT HUB75 para Raspberry PI. En caso de tener un HAT con multiples conexiones de HUB75, siempre utilizar la salida TOP para la primera fila del conjunto de paneles, y usar el resto de las salidas para las filas inferiores. El extremo opuesto del cable de datos debe conectarse en el "input" del panel, estos modulos tienen etiquetada su entrada y salida en la parte posterior. Ver las imagenes mostradas como referencia visual.

Para la conexión electrica, cada uno de los paneles LED tiene una entrada de cuatro pines para cables de alimentación. Es necesario tener una fuente de poder con salida de 5V y un minimo de 3A, para cumplir con los criterios de alimentación en los modulos LED.

![HUB75 conector](https://github.com/diegoalrv/pantallas-led/assets/148826389/5c03ffe1-eca1-42b8-bd50-4efc3d170ed7) ![HUB75 input](https://github.com/diegoalrv/pantallas-led/assets/148826389/f153e6ce-ce5e-4b19-8e2d-45ffa2d77037) ![Raspi HAT](https://github.com/diegoalrv/pantallas-led/assets/148826389/8b40b730-42ae-4416-929d-cd32de8903ee)


A continuación, se presenta un diagrama de conexiones, tanto para los datos como para la alimentación. Notar que la referencia (0,0) corresponde a la orientación superior izquierda de las gráficas que se deseen desplegar en el módulo, también se señala la orientación de las entradas y salidas de cada panel en la configuración.

![conexionModLED](https://github.com/diegoalrv/pantallas-led/assets/148826389/782bac34-8173-4207-a9f7-df2b5422b9ca.png)

### Configuración de Raspberry Pi

Luego de haber descargado los datos almancenados en este reposotorio. En el directorio ModuloLED, encontrará un script llamado `MenuPantalla.sh`, en este menú se puede hacer dos acciones en concreto:

- Configurar parámetros de la implementación, modificando variables del codigo base.
- Desplegar una imagen a partir de un archivo imagen jpg o png almacenada en el sistema.

  #### Configuración de Parámetros

  Entre las opciones de configuración en el codigo base para el funcionamiento del panel se muestran en la siguiente tabla:

  | Parámetro | Variable código base | Rango de valores |
  | ------------ | ------------ | ------------ |
  | N° de filas de pixeles en un panel. | `options.rows` | PANEL |
  | N° de columnas de pixeles en un panel. | `options.col` | PANEL |
  | N° de filas de paneles montados | `options.parallel` | 1 - 3 |
  | N° de columnas de paneles montados | `options.chain_length` | 1 - 3 |
  | Brillo | `options.brightness` | 0 - 100 |
  | Mapeo GPIO para HAT | `options.hardware_mapping` | `regular`, ver otras opciones [aquí](https://github.com/hzeller/rpi-rgb-led-matrix/blob/master/wiring.md#alternative-hardware-mappings) |
  | Multiplexación | `options.multiplexing` | 1 (por defecto) - 17 |
  | Retardo GPIO | `options.gpio_slowdown` | 1 - 5 |
  | Max. frecuencia de frames [Hz] | `options.limit_refresh_hz` | 30* - 240 (por defecto) |
  | Bits Resolución PWM | `options.pwm_bits` | 1 - 11 (por defecto) |
  

  **PANEL: Dado por el fabricante del panel comprado.**
  
  *Se pueden usar valores inferiores a 30 FPS, pero no se recomienda en términos de visibilidad

  ## Despliegue de imagenes

  Al seleccionar esta opción, se mostrarán todos los archivos de imagen guardados en el sistema de la Raspberry Pi. Se recomienda utilizar imagenes con la mimsa relacion de aspecto que la resolución de la pantalla montada para el despliegue. De lo contrario, la pantalla tendrá espacios en negro.

  ### Variables del Sistema Operativo

  Se propone un Sub-sistema que se encargue de manera dedicada al renderizado en la Matriz LED en forma continua. Para eso se implementa un *demonio* de Linux que esta continuamente dibujando en el display.

  Para ello se reserva el procesador 3, entregandoselele la `CPUAffinity=3` al proceso, de manera de garantizar el recurso computacional. Adicionalmente se modifica el Sistema Operativo para que quite el procesador del itineradoe usando `isocpus=3` en la variable de inicio `/boot/cmdline.txt`.

  Además se monta un directorio de `/srv/ledram` que tiene un tamaño de 32MB para disponer una *memoria de video* en RAM que permita a otros procesos actualizar el contenido que se despliega en el display. Para ello se modifica el `/etc/fstab` para que se cree el recurso automaticamente al iniciarse la Raspberry.

  #### Sub-sistema de renderizado

  Se define el directorio `/srv` donde se aloja el sub-sistema de renderizado. Esta compuesto del script `/srv/subsystem/led-driver.py` que es iniciado en forma automática por `systemd`.

  El script ve la hora de modificación del archivo `/srv/ledram/current.png` para determinar si debe o no actualizar la imagen que se está desplegando actualmente en el display cada 100 ms.

  De esta manera, cualquier usuario o proceso (`chmod 666`) puede escribir ese archivo. Siendo este sub sistema el encargado de leer el contenido de la imagen y renderizarlo en el display led en forma permanente.

  #### Instalación como servicio

  Todos estos pasos están automatizados en el script `install-service.sh` que debe ser ejecutado como `root`. 

  #### TODO

  Falta que el script detecte cuando se le solicita salir, para que elimine el archivo `/srv/ledram/current.png`, de tal manera de poder `systemctl stop led-driver.service` y `systemctl start led-driver.service` sin depender que la imagen se elimine en forma automatica al ser un directorio volatil
