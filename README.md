# TUCErradura-app
Aplicacion movil para el proyecto de Cerradura Electronica - Montajes e Instalaciones 2024

🚧 Work in progress....

## Estructura de carpetas sugerida

|Carpeta|Utilizacion|
|------|-----|
|src|Colocaremos el codigo fuente que genera la aplicacion, el firmware o cualquier otro componente distribuible para el usuario final|
|scratch|Podemos usarla libremente para desarrollar proyectos de prueba, funcionales o no pero que podrian en el futuro incorporarse a **src**<br>⚠️ **NO** deberiamos usarla como parte de una rama de desarrollo para src, todo lo que pueda quedar en produccion tiene que residir bajo **src** Sirve mas que nada para compartir esas ideas o intentos con el resto del equipo |

## Herramientas para usar Github

Si bien podemos usar la linea de comandos, hoy la mayoria de los IDEs, incluso la nueva version del IDE de Arduino que se basa en Visual Studio Code, tienen un soporte amplio que simplifica mucho las cosas.

Tal como sugirio Yamil, una herramienta interesante es Github Desktop que podemos encontrar en 

[Descargar Github Desktop](https://desktop.github.com/download)

## Guia rapida para uso del repositorio

1. Clonar el repositorio en la computadora local, esto genera una copia identica de lo que existe en ese momento en el origen remoto. Siempre trabajaremos con copias locales haciendo cambios en los archivos y realizando *commits* cuando nos resulte conveniente (en general cuando se termina una feature nueva pero podemos hacerlo en cualquier momento)<br><br>
2. La rama llamada **main** es la que contiene la version productiva del sofware, deberiamos tratar de no realizar pruebas o experimentos en la misma ya que pone en riesgo la integridad del producto, esto no significa no poner codigo nuevo sino que no pongamos carpetas con proyectos del estilo "vamos a ver si funciona ..." que no se corresponda con algun modulo del proyecto: cada proyecto bajo src deberia ser un ejecutable o libreria que va a ponerse en produccion, no algo "desechable"<br><br>
3. Siempre que vayamos a trabajar sobre una nueva caracteristica, hacer pruebas o desarrollar una idea, creamos una rama nueva que puede tener nuestro nombre o bien nuestro nombre y una palabra o dos que facilite identificar de que se trata el trabajo sobre esa rama (ej: **carlos-probar-wifi** o **carlos-usr-check-fix**, el nombre de la rama puede ser cualquiera)<br><br>
4. Podemos tener varias ramas creadas, por ejemplo podria ser que **carlos-usr-check-fix** modifique codigo fuente en la carpeta src para solucionar un bug mientras que **carlos-probar-wifi** es una rama que agrega un proyecto a scratch que solo el usuario carlos va a modificar, si bien una vez que se suba el codigo al remoto todos lo veremos<br><br>
5. Cada vez que hagamos cambios importantes en cualquiera de nuestras ramas, o que el trabajo que hicimos sea importante en volumen tal vez, o simplemente tengamos ganas de hacerlo, podemos realizar un **commit**, que no es otra cosa que marcar un punto en la historia del codigo donde en un futuro podriamos volver: es un deshacer a gran escala (es mas que eso pero por ahora podemos verlo asi). Cada commit requiere un comentario, tratemos de ser especificos con lo que hicimos (evitar el famoso "modificaciones varias") para que podamos saber cuando veamos el historial cuando hicimos cada cosa.<br><br>
6. Los commits son siempre locales, no se puede hacer un commit en el remoto. Cuando necesitemos realizar una subida de nuestro repo al origen, que implicara que todos nuestros commits en nuestra rama se publicaran en github para que cualquiera los vea, tenemos que hacer una operacion **push**. Luego de esto podemos ver que en la web de github nuestra rama aparece con el commit y comentario mas reciente.<br><br>
7. Y que pasa si queremos sincronizar nuestro repositorio local con cambios que hayan hecho otros usuarios en otras ramas, incluso en main? En ese caso veremos la opcion **fetch** que se encarga de bajar los cambios desde el origen a una especie de "cache" local pero sin modificar nuestro repo. La operacion **pull** toma esa info de cambios que bajamos desde el remoto y la integra con los commits que tenemos localmente. Esta ultima operacion puede que provoque conflictos por ejemplo si alguien toco una rama nuestra, o dos personas modificaron main, cosa que no deberia pasar porque cualquier cambio siempre tiene que venir desde una rama, y no desde main.<br><br>
8. Sacando los conflictos que se pueden dar por error de uso, hay otros que seguro ocurriran cuando dos usuarios que estaban trabajando en features quieren integrarlas en main. Por ejemplo la rama **carlos-usr-check-fix** que vimos recien modifica el archivo *user.cpp* se realiza el proceso de integracion a main y todo funciona perfecto. Luego tenemos que otro usuario dueño de la rama **pepe-implem-seguridad** modifica tambien *user.cpp*. Git va a detectar que el *user.cpp* que hay ahora en main no es el mismo que habia cuando pepe empezo a trabajar en su rama! Puede haber suerte y que git interprete que no hay conflictos pero en general ocurre que un usuario borra una linea y el otro no o cosas similares. En ese caso se produce un conflicto en la operacion y las herramientas nos ofreceran hacer un **merge** que basicamente es leer ambos archivos (el que intenta subir pepe y el que esta en main) y ver con que cambios nos quedamos. Por ahora no nos preocupemos por esto pero tengamoslo en cuenta, casi siempre hay una persona que se ocupa de mergear ramas en main para que estos conflictos se solucionen de una manera centralizada.

