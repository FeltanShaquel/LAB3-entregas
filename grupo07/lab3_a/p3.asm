.ORIG x3000
NUM1    .FILL #14336   ; Ejemplo: Valor en Q3.12
NUM2    .FILL #256     ; Ejemplo: Valor en Q7.8

        LD R1, NUM2    ; Cargar NUM2 (Q7.8)
        ; Para desplazar 4 bits a la izquierda (multiplicar por 16):
        ; R1 = R1 + R1 (x2) -> x4 -> x8 -> x16
        ADD R1, R1, R1 ; x2
        ADD R1, R1, R1 ; x4
        ADD R1, R1, R1 ; x8
        ADD R1, R1, R1 ; x16 (ahora está alineado a Q3.12)
        
        LD R2, NUM1    ; Cargar NUM1 (Q3.12)
        ADD R3, R2, R1 ; R3 = NUM1 + NUM2_alineado (Suma en Q3.12)
        
        HALT
        
.END