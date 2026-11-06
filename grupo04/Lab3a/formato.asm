; ============================================================
; LABORATORIO 3-a - FORMATO Q
; ACTIVIDADES EN LENGUAJE ASSEMBLY - LC-3
;
; NUM1 = 5.25  -> Q4.11 -> x2A00
; NUM2 = 2.50  -> Q7.8  -> x0280
;
; Punto 3:
;   Convertir NUM2 de Q7.8 a Q4.11.
;   Realizar suma y resta entre NUM1 y NUM2.
;
; Punto 4:
;   Multiplicar NUM1(Q4.11) por NUM2(Q7.8).
;   El producto queda inicialmente con 19 bits fraccionarios.
;   Luego se ajusta nuevamente a Q7.8.
;
; ============================================================


        .ORIG x3000


; ============================================================
; CARGA DE LOS NUMEROS
; ============================================================

        LD R1, NUM1          ; R1 = NUM1 en Q4.11
        LD R2, NUM2          ; R2 = NUM2 en Q7.8


; ============================================================
; PUNTO 3 - COMPATIBILIZACION DE FORMATOS
;
; NUM1 -> Q4.11
; NUM2 -> Q7.8
;
; Para convertir Q7.8 a Q4.11 se necesitan 3 bits
; fraccionarios adicionales:
;
;       11 - 8 = 3
;
; Por lo tanto:
;
;       NUM2_Q11 = NUM2_Q8 * 2^3
;       NUM2_Q11 = NUM2_Q8 * 8
;
; Como LC-3 no posee instruccion de desplazamiento,
; se realizan tres duplicaciones mediante ADD.
; ============================================================

        ADD R3, R2, R2       ; R3 = R2 * 2
        ADD R3, R3, R3       ; R3 = R2 * 4
        ADD R3, R3, R3       ; R3 = R2 * 8

        ST R3, NUM2_Q11      ; Guardar NUM2 convertido a Q4.11


; ============================================================
; SUMA
;
; Ambos operandos estan ahora en Q4.11:
;
;       NUM1       -> Q4.11
;       NUM2_Q11  -> Q4.11
;
; Por lo tanto pueden sumarse directamente.
; ============================================================

        ADD R4, R1, R3       ; R4 = NUM1 + NUM2_Q11

        ST R4, SUMA_Q11      ; Guardar resultado


; ============================================================
; RESTA
;
; Para realizar:
;
;       NUM1 - NUM2_Q11
;
; se obtiene el complemento a dos de NUM2_Q11:
;
;       -NUM2_Q11 = NOT(NUM2_Q11) + 1
;
; y luego se suma a NUM1.
; ============================================================

        NOT R5, R3           ; R5 = NOT(NUM2_Q11)
        ADD R5, R5, #1       ; R5 = -NUM2_Q11

        ADD R5, R1, R5       ; R5 = NUM1 - NUM2_Q11

        ST R5, RESTA_Q11     ; Guardar resultado


; ============================================================
; PUNTO 4 - MULTIPLICACION
;
; NUM1 esta en Q4.11
; NUM2 esta en Q7.8
;
; Al multiplicar:
;
;       Q4.11 * Q7.8
;
; los bits fraccionarios se suman:
;
;       11 + 8 = 19
;
; Por lo tanto el producto queda inicialmente en Q?.19.
;
; Como LC-3 trabaja con registros de 16 bits y el producto
; puede superar los 16 bits, se utiliza una representacion
; interna de dos palabras.
;
; Para facilitar el manejo del acarreo se utiliza una base
; de 2^15:
;
;       PRODUCTO = PRODUCTO_ALTO * 2^15 + PRODUCTO_BAJO
;
; PRODUCTO_BAJO siempre utiliza solamente 15 bits.
;
; Los valores utilizados son positivos.
; ============================================================

        LD R1, NUM1          ; R1 = NUM1
        LD R2, NUM2          ; R2 = NUM2

        AND R3, R3, #0       ; R3 = producto bajo = 0
        AND R4, R4, #0       ; R4 = producto alto = 0

        ADD R5, R2, #0       ; R5 = cantidad de sumas


; ============================================================
; MULTIPLICACION POR SUMAS SUCESIVAS
;
; Producto = NUM1 * NUM2
;
; Se suma NUM1 tantas veces como indique NUM2.
;
; Si la suma del producto bajo supera 15 bits, se genera
; un acarreo hacia la parte alta.
; ============================================================

MULT_LOOP

        ADD R3, R3, R1       ; producto_bajo += NUM1

        BRn MULT_CARRY       ; Si pasa de 32767, hay acarreo

        BRnzp MULT_NEXT


MULT_CARRY

        LD R6, MASK15        ; R6 = x7FFF

        AND R3, R3, R6       ; conservar solamente 15 bits

        ADD R4, R4, #1       ; incrementar parte alta


MULT_NEXT

        ADD R5, R5, #-1      ; decrementar contador

        BRp MULT_LOOP        ; repetir mientras R5 > 0


; ============================================================
; GUARDAR PRODUCTO
; ============================================================

        ST R3, PRODUCTO_BAJO
        ST R4, PRODUCTO_ALTO


; ============================================================
; AJUSTE DEL PRODUCTO
;
; El producto esta en Q?.19.
;
; Queremos expresarlo nuevamente en Q7.8.
;
; Por lo tanto debemos eliminar:
;
;       19 - 8 = 11
;
; bits fraccionarios.
;
; Esto equivale a dividir el producto por:
;
;       2^11 = 2048
;
; Como:
;
;       PRODUCTO = ALTO * 2^15 + BAJO
;
; entonces:
;
;       PRODUCTO / 2^11
;
;       = ALTO * 2^4 + BAJO / 2^11
;
;       = ALTO * 16 + BAJO / 2048
;
; Se realiza la primera parte mediante cuatro
; duplicaciones y la segunda mediante restas sucesivas.
; ============================================================


; ------------------------------------------------------------
; ALTO * 16
; ------------------------------------------------------------

        ADD R6, R4, R4       ; R6 = ALTO * 2
        ADD R6, R6, R6       ; R6 = ALTO * 4
        ADD R6, R6, R6       ; R6 = ALTO * 8
        ADD R6, R6, R6       ; R6 = ALTO * 16


; ------------------------------------------------------------
; BAJO / 2048
;
; Se resta 2048 hasta que el valor sea negativo.
; Cada resta representa una unidad en la parte entera
; del resultado.
; ------------------------------------------------------------

        ADD R7, R3, #0       ; R7 = PRODUCTO_BAJO

        LD R0, MENOS_2048    ; R0 = -2048


DIV_2048_LOOP

        ADD R7, R7, R0       ; R7 = R7 - 2048

        BRn DIV_2048_FIN     ; si es negativo, terminar

        ADD R6, R6, #1       ; incrementar resultado

        BRnzp DIV_2048_LOOP


DIV_2048_FIN

        ST R6, PRODUCTO_Q8   ; resultado final en Q7.8


        HALT


; ============================================================
; DATOS
; ============================================================

; ------------------------------------------------------------
; Numeros originales ya convertidos a formato Q
; ------------------------------------------------------------

NUM1
        .FILL x2A00          ; 5.25 * 2048 = 10752

NUM2
        .FILL x0280          ; 2.50 * 256 = 640


; ------------------------------------------------------------
; Resultados del punto 3
; ------------------------------------------------------------

NUM2_Q11
        .BLKW 1              ; NUM2 convertido de Q7.8 a Q4.11

SUMA_Q11
        .BLKW 1              ; NUM1 + NUM2_Q11

RESTA_Q11
        .BLKW 1              ; NUM1 - NUM2_Q11


; ------------------------------------------------------------
; Resultados del punto 4
; ------------------------------------------------------------

PRODUCTO_BAJO
        .BLKW 1

PRODUCTO_ALTO
        .BLKW 1

PRODUCTO_Q8
        .BLKW 1              ; producto final expresado en Q7.8


; ------------------------------------------------------------
; Constantes auxiliares
; ------------------------------------------------------------

MASK15
        .FILL x7FFF          ; mascara para conservar 15 bits

MENOS_2048
        .FILL xF800          ; -2048 en complemento a dos


        .END