.ORIG x3000
    LD R1, NUM1        ; R1 = Multiplicando (ej: Q3.12 -> #14336)
    LD R2, NUM2        ; R2 = Multiplicador  (ej: Q7.8  -> #256)
    AND R3, R3, #0     ; R3 = Acumulador del producto (parte baja)
    
    MULT_LOOP
        BRz MULT_FIN       ; Si el multiplicador es 0, terminamos el bucle
        ADD R3, R3, R1     ; Acumulador = Acumulador + NUM1
        ADD R2, R2, #-1    ; Decrementar el contador del multiplicador
        BRnzp MULT_LOOP

    MULT_FIN
        
        AND R4, R4, #0     ; R4 contendrá el cociente ajustado
        LD R5, NEG_256     ; R5 = -256 (para restar mediante bucle)
        
    ADJUST_LOOP

        ADD R3, R3, R5     ; R3 = R3 - 256
        BRn SAVE_RESULT    ; Si da negativo, terminamos la división entera
        
        ADD R4, R4, #1     ; Incrementamos el cociente
        BRnzp ADJUST_LOOP

    SAVE_RESULT
        ST R4, RESULTADO   ; Guardar resultado final ajustado en Q3.12
        HALT

    NUM1       .FILL #14336     ; Número 1 en formato Q3.12 (ej: 3.5 * 4096)
    NUM2       .FILL #256       ; Número 2 en formato Q7.8  (ej: 1.0 * 256)
    NEG_256    .FILL #-256      ; Complemento a 2 de 256 para restar
    RESULTADO  .BLKW 1

.END