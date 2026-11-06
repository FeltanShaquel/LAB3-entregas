; Prueba del conversor del grupo 15.
; Cambiar ENTRADA para probar otro valor.
; Con ENTRADA = 516, SALIDA debe quedar en 32.
; Revisar el resultado y los registros antes de HALT.

        .EXTERNAL G15_Q312_Q78-G15_Q312_Q78
        .ORIG x3000
G15_INICIO_PRUEBA
        LD R1, G15_INICIAL_R1
        LD R2, G15_INICIAL_R2
        LD R3, G15_INICIAL_R3
        LD R4, G15_INICIAL_R4
        LD R5, G15_INICIAL_R5
        LD R0, ENTRADA
        JSR G15_Q312_Q78-G15_Q312_Q78
        ST R0, SALIDA
G15_FIN_PRUEBA
        HALT
ENTRADA .FILL #516
SALIDA  .BLKW #1
G15_INICIAL_R1 .FILL x1111
G15_INICIAL_R2 .FILL x2222
G15_INICIAL_R3 .FILL x3333
G15_INICIAL_R4 .FILL x4444
G15_INICIAL_R5 .FILL x5555
        .END
