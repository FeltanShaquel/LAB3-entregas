# Grupo 07 · Máximo Común Divisor (MCD) + Mínimo Común Múltiplo (MCM)

**Consigna:** Desarrollar un programa en lenguaje ensamblador LC-3 que calcule el máximo común divisor (MCD) y el mínimo común múltiplo (MCM), ambos de dos enteros.

## Integrantes
- Zabala, Álvaro Martín (@alvaromartinzabala-ing)
- Behr, Pedro Sebastián (@pedrobehr21-source)

---
## Archivos del Repositorio:
- `README.md`: instrucciones breves, integrantes y descripción general del proyecto.

## lab3_a
- `programa.c`: solicita los números, realiza las conversiones Q y calcula las operaciones.
- `p3.asm`: convierte y alinea el valor Q7.8 para realizar la suma en Q3.12.
- `p4.asm`: implementa la multiplicación y el ajuste del resultado en ensamblador LC-3.

## lab3_b
- `mcd_mcm_v3.asm`: Programa autónomo e interactivo optimizado en ensamblador LC-3. Lee dos números enteros con signo por consola, calcula el MCD y el MCM mediante restas y sumas sucesivas, y muestra los resultados en pantalla.
- `mainv3.c`: Programa auxiliar en C que implementa el modelo matemático de referencia en formato Q15.0, un simulador funcional ciclo a ciclo de la arquitectura LC-3 y un banco de pruebas automatizado (`--test`) con 63.750 casos de validación.
- `informe_lab3_MCD_MCM.pdf`: documentación técnica, rangos, estado de simulación y bitácora de avances.

---

## Especificaciones para Verificación (Formato Punto Fijo, Rangos y Precisión)

El algoritmo opera íntegramente con divisores y múltiplos enteros utilizando sumas y restas sucesivas.

| Parámetro | Especificación adoptada | Justificación técnica |
| :--- | :--- | :--- |
| **Formato de punto fijo** | **Q15.0** (complemento a 2, 16 bits) | 1 bit de signo y 15 bits de magnitud entera; 0 bits fraccionarios. |
| **Rango de entrada ($A, B$)** | **$[-32767, 32767]$** (`x8001` a `x7FFF`) | Se excluye `-32768` (`x8000`) porque su valor absoluto (`+32768`) no es representable en complemento a dos de 16 bits (Q15.0). |
| **Rango de salida (MCD)** | **$[0, 32767]$** | Nunca desborda: el MCD es menor o igual que $\max(\vert{}A\vert{}, \vert{}B\vert{}) \le 32767$. Se cumple $\text{MCD}(0, B) = \vert{}B\vert{}$ y $\text{MCD}(0, 0) = 0$. |
| **Rango de salida (MCM)** | **$[0, 32767]$** (exacto) | Si el MCM real supera `32767` (*overflow*), el bucle corta de inmediato (*Early Exit*) y devuelve el valor centinela **`-32768` (`x8000`)** como aviso de desbordamiento. |
| **Precisión (mín. y máx.)** | **Exacta** (resolución $2^0 = 1$, error $= 0$) | No existe error de truncamiento ni redondeo dado que $\min(\vert{}A\vert{}, \vert{}B\vert{}) / \text{MCD}$ es siempre una división entera exacta. |


### Para probar `mainv3.c`
1. gcc -O2 mainv3.c -o mainv3
2. ./mainv3          # Modo interactivo (muestra iteraciones e instrucciones por opcode)
3. (Para testear) ./mainv3 --test   # Ejecuta el test de 63.750 pruebas


### Para probar `mcd_mcm_v3.asm`
1. Abrir `mcd_mcm_v3.asm` en el simulador de LC-3.
2. Ensamblar el programa. *(Nota: si se utiliza un simulador local que no inicializa el puntero de pila `R6`, descomentar la primera instrucción `LD R6, STACK_BASE`).*
3. Ejecutar desde la dirección inicial `x3000`.
4. Ingresar los dos números enteros en el rango `[-32767, 32767]` por consola, uno por línea (presionando Enter tras cada número):

```text
Ingresa el primer numero: 12
Ingresa el segundo numero: 18
MCD = 6
MCM = 36
