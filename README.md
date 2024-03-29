# Programación de Sistemas de Telecomunicación
Prácticas correspondientes a la asignatura de PST

## Práctica 1
### Contar palabras

Programa en Ada relacionado que analiza las líneas de un fichero y almacena en una lista dinámica las palabras diferentes que contiene, incluyendo el número de veces que aparece cada una. Además el programa permite añadir, borrar, o buscar palabras a la lista, y al terminar muestra la palabra más repetida de la lista.

## Práctica 2
### Mini-Chat en modo cliente/servidor

Programas en Ada que permiten implementar un sistema de chat entre usuarios, siguiendo el modelo cliente/servidor.

El programa cliente puede comportarse de dos maneras: en modo escritor, o en modo lector. Si un cliente es escritor puede enviar mensajes al servidor del chat. Si un cliente es lector puede recibir los mensajes que envía el servidor.

El servidor se encarga de recibir los mensajes procedentes de los clientes escritores, y reenviárselos a los clientes lectores.

En una sesión de chat participará un programa servidor y varios programas clientes (lectores y escritores). Cada usuario del chat tiene que arrancar 2 programas cliente: uno escritor, que lee del teclado y envía mensajes, y uno lector, que recibe mensajes del servidor y los muestra en la pantalla.

Como extensión de la práctica: un tercer programa en Ada que opera como administrador del chat.

## Práctica 3
### Mini-Chat v2.0 en modo cliente/servidor

Programas en Ada que permiten implementar un sistema de chat entre usuarios, siguiendo el modelo cliente/servidor.

Mini-Chat v2.0 mejora la implementación y la interfaz de uso de la anterior versión de Mini-Chat. La programación asíncrona mediante el uso de los manejadores o handlers de Lower_Layer_UDP para recibir mensajes permite que el programa cliente pueda realizar concurrentemente las funciones de lector y de escritor definidas en la anterior práctica, sin necesidad de arrancar un programa cliente en modo escritor para leer de la entrada estándar (teclado) y enviar mensajes al servidor, y otro programa cliente en modo lector para recibir del servidor y mostrarlos en la salida estándar (pantalla).

En una sesión de chat participará un programa servidor y varios programas cliente, uno por cada usuario.
