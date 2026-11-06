.ORIG x3000

; ========================================================
; 1. CARGA DE DATOS (Ya formateados en Q)
; Elegimos números pequeños para no desbordar los 16 bits.
; Num1 real = 0.0625  -> Q3.12 = 0.0625 * 4096 = 256
; Num2 real = 0.125   -> Q7.8  = 0.125 * 256 = 32
; ========================================================
LD R1, NUM1_Q3_12   ; R1 = 256 (Formato Q3.12)
LD R2, NUM2_Q7_8    ; R2 = 32 (Formato Q7.8)

; ========================================================
; PUNTO 3: Compatibilización y Suma
; Convertir R1 (Q3.12) a Q7.8. Equivale a hacer R1 >> 4.
; Simulamos el >> 4 dividiendo por 2^4 (16) mediante restas.
; ========================================================
AND R3, R3, #0      ; R3 será el contador (cociente)
LD R4, NEG_16       ; R4 = -16

DIV16_LOOP
    ADD R1, R1, R4  ; R1 = R1 - 16
    BRn END_DIV16   ; Si da negativo, terminamos el bucle
    ADD R3, R3, #1  ; Sumamos 1 al contador
    BRnzp DIV16_LOOP
END_DIV16

; R3 ahora tiene Num1 convertido a Q7.8 (256 / 16 = 16)
; Sumamos los dos números (R3 + R2)
ADD R5, R3, R2      ; R5 = Suma en Q7.8 (16 + 32 = 48)
ST R5, RES_SUMA     ; Guardamos el resultado de la suma

; ========================================================
; PUNTO 4: Multiplicación y Ajuste
; Multiplicamos NUM1 (Q3.12) * NUM2 (Q7.8) crudo mediante
; sumas sucesivas.
; ========================================================
LD R1, NUM1_Q3_12   ; Recargamos R1 (se consumió en la resta)
LD R2, NUM2_Q7_8    ; R2 es nuestro contador de multiplicador (32)
AND R6, R6, #0      ; R6 = Acumulador de la multiplicación

MULT_LOOP
    ADD R2, R2, #0  ; Evaluamos el multiplicador
    BRz END_MULT    ; Si llega a 0, terminamos de sumar
    ADD R6, R6, R1  ; Acumulamos: R6 = R6 + R1
    ADD R2, R2, #-1 ; Descontamos 1 al multiplicador
    BRp MULT_LOOP   ; Repetimos mientras sea positivo
END_MULT

; R6 tiene la multiplicación cruda en Q10.20 (256 * 32 = 8192)
; Ajuste a Q7.8: Equivale a >> 12 (Dividir por 2^12 = 4096)
AND R7, R7, #0      ; R7 = Contador para el resultado ajustado
LD R4, NEG_4096     ; R4 = -4096

DIV4096_LOOP
    ADD R6, R6, R4  ; R6 = R6 - 4096
    BRn END_DIV4096 ; Si da negativo, terminamos
    ADD R7, R7, #1  ; Incrementamos resultado ajustado
    BRnzp DIV4096_LOOP
END_DIV4096

; R7 tiene el resultado final ajustado a Q7.8 (8192 / 4096 = 2)
ST R7, RES_MULT     ; Guardamos el resultado final

HALT                ; Fin del programa

; ========================================================
; ZONA DE DATOS Y VARIABLES
; ========================================================
NUM1_Q3_12  .FILL #256    ; Operando 1 en formato Q3.12
NUM2_Q7_8   .FILL #32     ; Operando 2 en formato Q7.8
NEG_16      .FILL #-16    ; Constante para shift >> 4
NEG_4096    .FILL #-4096  ; Constante para shift >> 12
RES_SUMA    .BLKW 1       ; Memoria para guardar la suma
RES_MULT    .BLKW 1       ; Memoria para guardar la multiplicación

.END
