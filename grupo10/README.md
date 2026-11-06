# Grupo 10 · División

**Consigna:** Por método de división larga

## Integrantes

- Benitez, Denis Adrian (@ElAndiWh3)
- Silvero Zapani, Matias Facundo Tobias (@PurpleMaZ)
- Pintos, Daiana Stefani Luzmila (@Luz105)

## Archivos

- `division.asm`: Módulo `DIVISION` con la subrutina `DIV_LONG` (la que usa el menú del grupo 27, en Q7.8) y `DIVIDIR` (el núcleo general en el que se apoya). Sin `.ORIG` y terminado con `.END`, como pide la plantilla de subrutinas. Es un módulo para usar desde otro programa, por eso no trae programa principal (ver abajo cómo probarlo).

## Cómo probarlo

El módulo se prueba llamándolo desde un programa principal. Hay dos formas.

**Con un programa principal mínimo**

- Abrir <https://lc3.lgrum.xyz/> y cargar `division.asm` en la sección de Archivos.
- Crear un archivo nuevo, `main.asm`, con este contenido:

```asm
            .ORIG x3000
            .EXTERNAL DIVISION-DIV_LONG

            LD   R0, A               ; a = 5,5 en Q7.8
            LD   R1, B               ; b = 2,0 en Q7.8
            LD   R5, DIV_PTR
            JSRR R5                  ; R0 = a / b en Q7.8
            HALT                     ; R0 = x02C0 = 704 = 2,75

A           .FILL #1408
B           .FILL #512
DIV_PTR     .FILL DIVISION-DIV_LONG
            .END
```

- Pulsar en opciones (`...`) de `main.asm` y elegir **Usar como entrada** (si no está ya como entrada).
- **Ensamblar**. La pestaña de problemas tiene que quedar en 0.
- Pulsar **▶ Continuar** para ejecutar hasta el `HALT`.
- Mirar los registros y la memoria: R0 tiene que valer `x02C0` (704, que en Q7.8 es 2,75) y la etiqueta `ESTADO` tiene que valer `x0000`. Cambiando los valores de `A` y `B` se prueban otros casos.

**Con el menú del grupo 27**

Conectar `DIV_LONG` al nodo de la división larga como se explica en "Cómo usarla desde otro programa", cargar todos los archivos del menú más `division.asm`, ensamblar `main.asm` del menú y ejecutar. En el menú se elige `8` (división) y `0` (LONG DIVISION), y se ingresan `a` y `b`. Casos probados:

| a | b | Resultado |
| --- | --- | --- |
| 5.5 | 2 | 2.75 |
| -5.5 | 2 | -2.75 |
| 1 | 3 | cerca de 0.332 (en Q7.8 es 0.33203125) |
| -128 | 1 | -128 |
| 100 | 0.5 | no entra en Q7.8: satura en 127.99609375 y `ESTADO` queda en 2 |
| 1 | 0 | 0, y `ESTADO` queda en 1 |

**Ejemplo de entrada y salida**

| Subrutina | Entrada | Salida |
| --- | --- | --- |
| `DIV_LONG` | R0 = 1408 (5,5 en Q7.8), R1 = 512 (2,0 en Q7.8) | R0 = 704, que en Q7.8 es 2,75 |
| `DIVIDIR` | R0 = 12868 (3,14159 en Q3.12), R1 = 95 (0,37 en Q7.8), R2 = 6 | R0 = 8668, que en Q5.10 es 8,46484375 |

El valor real de 3,14159 ÷ 0,37 es 8,4908. Con las entradas ya cuantizadas es 8,4658, y `DIVIDIR` entrega 8,4648 (trunca hacia cero).

## Subrutinas

Siguen la plantilla de subrutinas del repositorio: R0 es la salida, R1 y R2 son entradas, no se usa R6 y todos los registros vuelven como se entregaron (incluido R7). Los registros se guardan en palabras de memoria con `ST` y se restauran con `LD`, por eso las rutinas no son reentrantes.

- `DIV_LONG`: División larga con signo para el banco de algoritmos y el menú del grupo 27, que pasa `a` y `b` en Q7.8 y espera el resultado en Q7.8.
    - Entrada: R0 = a (Q7.8), R1 = b (Q7.8).
    - Salida: R0 = a ÷ b en Q7.8, truncado hacia cero.
    - Estado: la palabra `ESTADO` queda en 0 si salió bien, 1 si el divisor es 0 y 2 si el cociente no entra en Q7.8 (el resultado queda saturado en x7FFF o x8000).
    - Cómo funciona: llama a `DIVIDIR` con `s = 8` (`s = n_res + n_b − n_a = 8 + 8 − 8`). Agrega 8 instrucciones por llamada y 10 palabras de memoria.
- `DIVIDIR`: Núcleo general de la división larga con signo, con los dos operandos en el formato Q que quiera quien la llama.
    - Entrada: R0 = dividendo, R1 = divisor (enteros de 16 bits con signo, cada uno en su formato Q), R2 = `s` (cantidad de bits que se desplaza el dividendo a la izquierda antes de dividir).
    - Salida: R0 = cociente en el formato de salida, truncado hacia cero.
    - Estado: igual que `DIV_LONG`.

## Algoritmo

La división larga binaria calcula el cociente bit a bit, como la división a mano pero en base 2. No tiene un único autor conocido: es el procedimiento de la división en papel llevado a binario, y en aritmética de computadoras se lo llama división con restauración (*restoring division*). Su objetivo es dividir usando solo sumas, restas y desplazamientos, que son las operaciones que la LC-3 base sí tiene (no tiene división, multiplicación ni desplazamiento a la derecha).

1. Signo: se trabaja con los valores absolutos y el signo del cociente se obtiene contando cuántos operandos eran negativos (la LC-3 no tiene XOR).
2. Alineación: el dividendo se desplaza `s` bits a la izquierda y queda en 32 bits (dos registros).
3. Desborde: si la palabra alta del dividendo es mayor o igual que el divisor, el cociente no entra en 16 bits.
4. Lazo de 16 vueltas: se desplaza el par resto:cociente un bit a la izquierda; si el resto es mayor o igual que el divisor, se le resta y el bit nuevo del cociente vale 1.
5. Cierre: se aplica el signo y se controla el rango.

**Iteraciones:** 16 fijas, una por bit del cociente, sin importar los valores. Cada llamada a `DIV_LONG` ejecuta entre 27 y 327 instrucciones (promedio 228) y cada llamada a `DIVIDIR` entre 19 y 361 (promedio 212), medido en un emulador de la LC-3 aparte del simulador del curso. El módulo completo ocupa 106 palabras, con sus datos.

## Formato de punto fijo, rango y precisión

Todo el cálculo se hace con enteros de 16 bits que representan valores en punto fijo Qm.n (1 bit de signo, m bits enteros y n fraccionarios, con m + n = 15; el valor se guarda como `raw = valor × 2^n`, en complemento a 2). No hay emulación de punto flotante.

**`DIV_LONG` (Q7.8 ÷ Q7.8 → Q7.8)**

- Entrada: a y b de −128 a 127,996, con resolución 1/256 = 0,00390625. El divisor no puede ser 0.
- Salida: Q7.8, de −128 a 127,996. Si el cociente no entra (por ejemplo 100 ÷ 0,5 = 200) la rutina satura en x7FFF o x8000 y deja `ESTADO` en 2.
- Precisión máxima: la división agrega un error menor a 1 LSB (0,0039), porque trunca hacia cero.
- Precisión mínima: la domina la cuantización de las entradas, que se amplifica cuando el divisor es chico. En 100.000 muestras aleatorias con |b| ≥ 1 el error máximo contra el valor real fue 0,19. Con |b| menor que 1 el error puede ser mayor y, además, el cociente puede salirse de rango.

**`DIVIDIR` (formatos Q cualesquiera)**

- El dividendo y el divisor pueden estar cada uno en cualquier Qm.n (pueden ser distintos).
- `s = n_res + n_b − n_a` tiene que estar entre 0 y 16. La rutina no lo valida: lo calcula quien la llama.
- El formato de salida queda determinado por `s` (`n_res = s + n_a − n_b`) y se elige según el divisor mínimo que se garantice. Para Q3.12 ÷ Q7.8:

| Salida | `s` | Divisor mínimo | Rango de salida | Resolución |
| --- | --- | --- | --- | --- |
| Q11.4 | 0 | cualquiera no nulo | −2048 a 2047,9375 | 0,0625 |
| Q5.10 | 6 | 0,25 | −32 a 31,999 | 0,000977 |
| Q3.12 | 8 | 1 | −8 a 7,9998 | 0,000244 |

- Precisión: el error del algoritmo es menor a 1 LSB del formato de salida. Contando la cuantización de las entradas, el error máximo en 100.000 muestras fue 0,16 para Q3.12 ÷ Q7.8 → Q5.10 con |b| ≥ 0,25. Con divisores de 1 LSB y salida Q11.4 llega a 328 y el resultado ya no sirve.

## Cómo usarla desde otro programa

El archivo se llama `division.asm`, así que los símbolos se importan como `DIVISION-DIV_LONG` y `DIVISION-DIVIDIR`.

Para el menú del grupo 27 (`main_menu.asm`) alcanza con importar `DIV_LONG` y reemplazar el `NULL_SUBRUTINE` del nodo de la división larga:

```asm
.EXTERNAL DIVISION-DIV_LONG
...
main_menu_sub_div_long      .FILL DIVISION-DIV_LONG     ; <- DIV_LONG
```

En el simulador hay que cargar también `division.asm` junto con los archivos del menú. Probado así con una copia local del menú: el nodo "DIVISION (LONG DIVISION)" devuelve los resultados esperados.

Desde cualquier otro programa, con `DIVIDIR` y un formato propio:

```asm
            .EXTERNAL DIVISION-DIVIDIR

            LD  R0, DIVIDENDO        ; a, en su formato Q
            LD  R1, DIVISOR          ; b, en su formato Q
            LD  R2, S                ; s = n_res + n_b - n_a (0 a 16)
            LD  R5, DIV_PTR          ; (R5 vuelve intacto)
            JSRR R5                  ; R0 = cociente en el formato de salida

DIV_PTR     .FILL DIVISION-DIVIDIR
```

Después de cada llamada conviene mirar la palabra `ESTADO` (0 = ok, 1 = divisor 0, 2 = desborde).

## Validación

- El modelo de referencia en Python (análisis en alto nivel previo al assembly) coincide con la aritmética entera exacta en 842.366 divisiones, en 7 combinaciones de formatos.
- `DIV_LONG` coincide con ese modelo en 40.361 casos y `DIVIDIR` en 42.166 (valores borde y aleatorios), en un emulador de la LC-3 aparte del simulador del curso. En todos los casos R1 a R7 vuelven intactos y las rutinas no escriben fuera de sus propias palabras de datos.
- En el simulador del curso, un programa principal de prueba con 21 casos (13 de `DIVIDIR` y 8 de `DIV_LONG`) llegó al `HALT` con el contador de fallas y el de casos pendientes en 0, es decir, todos los casos dieron lo esperado.
- Con el menú del grupo 27, los casos probados dieron los resultados esperados, incluidos el desborde y la división por cero.
