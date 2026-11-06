Reducción de ángulos - LC-3
El programa implementa una función de reducción de ángulos utilizando el lenguaje ensamblador LC-3.
Su objetivo es llevar un ángulo  en radianes de entrada al intervalo:
-pi/2<tita<pi/2
Para ello, suma o resta múltiplos de π hasta que el ángulo se encuentre dentro del intervalo establecido y asi obtener un angulo equivalente.

Formato de representación

Los valores se representan mediante punto fijo Q3.12.

Esto significa que los valores almacenados son enteros escalados por 2¹² = 4096.

Para convertir un valor almacenado a su equivalente real se utiliza:

Valor real = Valor almacenado / 4096

Para convertir un valor real a punto fijo:

Valor almacenado = Valor real × 4096

Constantes utilizadas

| Constante | Valor almacenado | Valor aproximado |

| π | 12867 | 3.14136 |
| -π | -12867 | -3.14136 |
| π/2 | 6433 | 1.57056 |
| -π/2 | -6434 | -1.57104 |

Las constantes son aproximaciones debido a la representación de punto fijo.

 Rango de entrada

El rango representable depende de la cantidad de bits disponible para los valores con signo en LC-3.

Al utilizar palabras de 16 bits, el rango de enteros almacenables es:

- Mínimo: -32768 
- Máximo: 32767  

En Q3.12, esto equivale aproximadamente al intervalo:

- Mínimo: -8 rad o -458.37°
- Máximo: 7.999755 rad o  458.36°
El algoritmo trabaja con valores expresados en este formato.

 Rango de salida

El resultado esperado debe encontrarse en el intervalo:

  Límite inferior: -π/2
  Límite superior: π/2

El resultado reducido queda almacenado en R4.

Verificación del funcionamiento

Para verificar el programa:

1. Cargar el programa en el simulador LC-3.
2. Ejecutar desde la dirección x3000.
3. Observar el contenido de R4 al finalizar.
4. Convertir el contenido de R4 a decimal dividiendo por 4096.
5. Comprobar que el resultado se encuentre dentro del intervalo esperado.

