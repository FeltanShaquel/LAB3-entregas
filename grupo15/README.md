# Grupo 15 · Laboratorios 3a y 3b

Nuestra parte del banco de funciones de LC-3 es la conversión de Q3.12 a Q7.8 mediante sumas sucesivas y corrimiento.

## Integrantes

- Lucca Santino Cruz (@Lucca168)
- Jose Maria Pona (@MajinBola)
- Lautaro Obregon (@LautaroObregon)

## Archivos

- [lab3a.asm](lab3a.asm) convierte el primer operando, suma, resta y multiplica dos valores de punto fijo que ya están cargados en memoria.
- [G15_Q312_Q78.asm](G15_Q312_Q78.asm) contiene el conversor de 3b. Es el archivo que publicamos en el simulador del grupo 8.
- [prueba_grupo8.asm](prueba_grupo8.asm) llama al conversor con un dato de ejemplo y permite comprobar la salida y los registros.

## Cómo funciona el conversor

El entero `N` de entrada representa `N / 4096`. Lo sumamos 16 veces. Si tomamos 16 como la unidad con cuatro bits fraccionarios, el producto `16 * N` conserva el valor real con 16 bits fraccionarios. Usamos dos palabras para guardar el producto completo, porque los extremos no caben en una palabra de 16 bits.

Después hacemos un corrimiento aritmético de ocho posiciones. Quedan ocho bits fraccionarios y el entero de salida es `floor(N / 16)`. Así aplicamos las sumas sucesivas y el corrimiento de la consigna. Cuando se descartan bits, el resultado se aproxima hacia abajo. Por ejemplo, el entero `-1` en Q3.12 devuelve `-1` en Q7.8.

| Dato | Formato | Entero con signo | Valor representado | Paso |
| --- | --- | --- | --- | --- |
| Entrada | Q3.12 | -32768 a 32767 | -8 a 7,999755859375 | 1/4096 |
| Salida que alcanza la función | Q7.8 | -2048 a 2047 | -8 a 7,99609375 | 1/256 |

El error absoluto respecto del valor de entrada ya codificado va de 0 a `15/4096`, aproximadamente 0,003662.

## Cómo probarlo

### Lab 3a

Ensamblar `lab3a.asm` como programa independiente, iniciar en `x3000` y detenerse antes de `HALT`. Los datos precargados representan 1,5 y -2,75. En memoria deben quedar estos resultados, interpretados como enteros con signo en Q7.8.

| Etiqueta | Entero esperado | Valor |
| --- | --- | --- |
| `SUMA_Q8` | -320 | -1,25 |
| `RESTA_Q8` | 1088 | 4,25 |
| `PRODUCTO_Q8` | -1056 | -4,125 |

Los indicadores `SUM_EST`, `RES_EST` y `PROD_EST` quedan en cero para este ejemplo.

### Lab 3b

1. Importar `G15_Q312_Q78.asm` y `prueba_grupo8.asm` en el [simulador del grupo 8](https://lc3.lgrum.xyz/).
2. Marcar `prueba_grupo8.asm` como entrada, ensamblar y detenerse en `G15_FIN_PRUEBA`, antes de `HALT`.
3. Con `ENTRADA = 516` (`x0204`), comprobar que `R0` y `SALIDA` valgan 32 (`x0020`). Ese entero representa 0,125 en Q7.8.
4. Comprobar que R1 a R5 conserven `x1111`, `x2222`, `x3333`, `x4444` y `x5555`. R6 debe mantener su valor inicial y R7 debe conservar la dirección de retorno de `JSR`.

Probamos el caso 516 en ese simulador y obtuvimos los valores esperados. El módulo quedó publicado allí con la cuenta del grupo 15. En las pruebas locales también comprobamos negativos y extremos, por ejemplo `-32768 → -2048` y `32767 → 2047` como enteros codificados.

## Cómo integrarlo con el grupo 27

La etiqueta de la función es `G15_Q312_Q78`. El programa principal carga el entero Q3.12 en R0 y recibe en ese mismo registro el resultado Q7.8. La función conserva R1 a R7 y deja NZP según el resultado. El guardado de registros usa posiciones de memoria propias de la subrutina, por lo que las llamadas deben ser secuenciales.

El archivo del módulo termina en `.END`. El `.ORIG` queda en el programa principal. La importación y la llamada de prueba se hacen así.

```asm
        .EXTERNAL G15_Q312_Q78-G15_Q312_Q78
        ; Cargar el dato Q3.12 en R0 antes de llamar.
        JSR G15_Q312_Q78-G15_Q312_Q78
```

Para conectarlo al menú, mantener la lectura como Q3.12 y mostrar el resultado con la conversión de salida Q7.8 (`Q8_TO_DQ16`). Para el guardado de registros seguimos el [ejemplo de subrutina del grupo 27](https://github.com/ingetiti/LAB3-entregas/blob/main/grupo27/como_programar_una_subrutina_RevRC.asm).

## Bitácora

### 4 de noviembre de 2026

Incorporamos el bucle de 16 sumas del prototipo y ampliamos el acumulador a dos palabras. Agregamos el ajuste de ocho bits y revisamos el signo y el acarreo. Con asistencia de IA se prepararon partes del código, la documentación y las verificaciones. Las pruebas automáticas locales comprobaron los 65.536 enteros de entrada del conversor.

### 5 de noviembre de 2026

Separamos la subrutina del programa de prueba y agregamos la restauración de los registros que usa. Probé el caso 516 en el simulador del grupo 8. Antes de `HALT`, R0 y `SALIDA` dieron 32 y los registros conservaron los valores previstos. Publiqué `G15_Q312_Q78.asm` en el simulador.

También se comprobó el ejemplo de 3a en PennSim. Las pruebas automáticas de la variante modular revisaron la salida, el retorno y la conservación de registros. Queda conectar el conversor con la interfaz del grupo 27 y comprobar la llamada desde el banco común.
