; Laboratorio 3a. LC-3 ORIGINAL. Datos ya codificados en memoria.
; Punto 3: convertir X Q3.12 a Q7.8; suma y resta en Q7.8.
; Punto 4: multiplicar X Q3.12 por Y Q7.8 y ajustar a Q7.8.
; Estado de cada operacion: 0=valido, 1=desbordamiento.
; Si hay desbordamiento, el resultado guardado es solo los 16 bits bajos.
        .ORIG x3000
        LD R0, X_Q12
        JSR CONVERTIR
        ST R0, X_Q8

; Suma: overflow firmado si operandos mismo signo y resultado distinto.
        LD R1, Y_Q8
        ADD R2, R0, R1
        ST R2, SUMA_Q8
        AND R3, R3, #0
        ADD R0, R0, #0
        BRn SUM_X_NEG
        ADD R1, R1, #0
        BRn SUM_FIN
        ADD R2, R2, #0
        BRzp SUM_FIN
        ADD R3, R3, #1
        BRnzp SUM_FIN
SUM_X_NEG
        ADD R1, R1, #0
        BRzp SUM_FIN
        ADD R2, R2, #0
        BRn SUM_FIN
        ADD R3, R3, #1
SUM_FIN
        ST R3, SUM_EST

; Resta: overflow si signos de X e Y difieren y resultado cambia signo X.
        NOT R2, R1
        ADD R2, R2, #1
        ADD R2, R0, R2
        ST R2, RESTA_Q8
        AND R3, R3, #0
        ADD R0, R0, #0
        BRn RES_X_NEG
        ADD R1, R1, #0
        BRzp RES_FIN
        ADD R2, R2, #0
        BRzp RES_FIN
        ADD R3, R3, #1
        BRnzp RES_FIN
RES_X_NEG
        ADD R1, R1, #0
        BRn RES_FIN
        ADD R2, R2, #0
        BRn RES_FIN
        ADD R3, R3, #1
RES_FIN
        ST R3, RES_EST

        LD R0, X_Q12
        LD R4, Y_Q8
        JSR MULTIPLICAR
        ST R0, PRODUCTO_Q8
        HALT

; R0 entrada Q12; R0 salida Q8; destruye R1,R2 y CC.
; DIV16 de focacode.docx (grupo 15), adaptada a enteros con signo.
CONVERTIR
        ADD R1, R0, #0
        AND R0, R0, #0
        ADD R2, R1, #0
        BRzp DIV16
        NOT R2, R2          ; ~N es no negativo, incluso para x8000
DIV16
        ADD R2, R2, #-16
        BRn DIV16_FIN
        ADD R0, R0, #1
        BRnzp DIV16
DIV16_FIN
        ADD R1, R1, #0
        BRzp DIV16_RET
        NOT R0, R0          ; floor(N/16) = ~floor((~N)/16) para N negativo
DIV16_RET
        RET

; R0 multiplicando firmado, R4 multiplicador firmado.
; R0 retorna producto Q8; PROD_EST indica overflow.
; Destruye R1..R6 y CC; mantiene R7 para RET.
; Acumular X abs(Y) veces y negar el producto si Y era negativo.
MULTIPLICAR
        ST R4, SIGNO_Y
        ADD R4, R4, #0
        BRzp MAG_LISTA
        NOT R4, R4
        ADD R4, R4, #1       ; x8000 se usa como contador unsigned 32768
MAG_LISTA
        AND R1, R1, #0       ; palabra baja
        AND R2, R2, #0       ; palabra alta
        AND R6, R6, #0
        ADD R0, R0, #0
        BRzp EXT_LISTA
        ADD R6, R6, #-1      ; extension del signo de X
EXT_LISTA
        ADD R4, R4, #0
        BRz MUL_TERMINO
MUL_SUMAR
        ADD R3, R1, #0
        ADD R1, R1, R0
        ADD R2, R2, R6
; Acarreo unsigned de la suma de las palabras bajas.
        ADD R3, R3, #0
        BRn MUL_VIEJO_NEG
        ADD R0, R0, #0
        BRzp MUL_SIN_CARRY
        ADD R1, R1, #0
        BRzp MUL_CARRY
        BRnzp MUL_SIN_CARRY
MUL_VIEJO_NEG
        ADD R0, R0, #0
        BRn MUL_CARRY
        ADD R1, R1, #0
        BRn MUL_SIN_CARRY
MUL_CARRY
        ADD R2, R2, #1
MUL_SIN_CARRY
        ADD R4, R4, #-1
        BRnp MUL_SUMAR      ; BRnp tambien admite el contador x8000
MUL_TERMINO
        LD R3, SIGNO_Y
        BRzp PROD_LISTO
; Negar R2:R1 en complemento a dos (incluido acarreo del +1).
        NOT R1, R1
        NOT R2, R2
        ADD R1, R1, #1
        BRnp PROD_LISTO
        ADD R2, R2, #1
PROD_LISTO
        ST R1, PROD_LO
        ST R2, PROD_HI
; Para que (producto >>12) quepa en 16 bits, los bits 31..27
; deben ser todos 0 o todos 1: mascara HI xF800.
        AND R6, R6, #0
        LD R3, MASCARA
        AND R3, R2, R3
        BRz PROD_CABE
        LD R5, LIMITE
        ADD R3, R3, R5
        BRz PROD_CABE
        ADD R6, R6, #1
PROD_CABE
        ST R6, PROD_EST
; Extraer bits 27..12. Con overflow no interpretar el resultado como valido.
        AND R0, R0, #0
        ADD R2, R2, R2
        ADD R2, R2, R2
        ADD R2, R2, R2
        ADD R2, R2, R2
        AND R4, R4, #0
        ADD R4, R4, #12
PROD_BIT_HI
        ADD R0, R0, R0
        ADD R2, R2, #0
        BRzp PROD_CERO_HI
        ADD R0, R0, #1
PROD_CERO_HI
        ADD R2, R2, R2
        ADD R4, R4, #-1
        BRp PROD_BIT_HI
        ADD R4, R4, #4
PROD_BIT_LO
        ADD R0, R0, R0
        ADD R1, R1, #0
        BRzp PROD_CERO_LO
        ADD R0, R0, #1
PROD_CERO_LO
        ADD R1, R1, R1
        ADD R4, R4, #-1
        BRp PROD_BIT_LO
        RET

X_Q12       .FILL #6144      ; 1.5 en Q3.12
Y_Q8        .FILL #-704      ; -2.75 en Q7.8
X_Q8        .BLKW 1
SUMA_Q8     .BLKW 1
RESTA_Q8    .BLKW 1
PRODUCTO_Q8 .BLKW 1
SUM_EST     .BLKW 1
RES_EST     .BLKW 1
PROD_EST    .BLKW 1
PROD_LO     .BLKW 1
PROD_HI     .BLKW 1
SIGNO_Y     .BLKW 1
MASCARA     .FILL xF800
LIMITE      .FILL x0800
        .END
