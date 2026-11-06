.ORIG x3000

MAIN    
        ; --- 1. INICIALIZACIÓN DE VARIABLES EN REGISTROS ---
        AND R1, R1, #0
        ADD R1, R1, #-2          ; R1 = -2 (Base)

        AND R2, R2, #0
        ADD R2, R2, #13         ; R2 = 13 (Exponente)

        AND R3, R3, #0
        ADD R3, R3, #1          ; R3 = 1 (Acumulador inicial)

       ; --- 2. CONFIGURACIÓN DE SIGNOS Y PARIDAD EN REGISTROS ---
        AND R6, R6, #0
        AND R0, R2, #1
        ADD R6, R6, R0          ; R6 (TMP_MEM) = R2 & 1 (guarda si el exponente es impar)

        AND R5, R5, #0          ; R5 (TMP_SIGN) = 0 por defecto (positivo)
        ADD R1, R1, #0
        BRzp LOOP_W             ; Si es positivo o cero, salta directo al bucle principal
        
        ADD R5, R5, #1          ; Si la base es negativa, R5 = 1
        NOT R1, R1
        ADD R1, R1, #1          ; Base positiva temporalmente para operar

        ; --- 3. BUCLE PRINCIPAL DE EXPONENCIACIÓN RÁPIDA ---
LOOP_W  
        ADD R2, R2, #0
        BRnz POST_PROC          ; Si exponente <= 0, termina

        AND R0, R2, #1
        BRz L_SHIFT             ; Si el bit es 0, salta la multiplicación

        ; Multiplicación por sumas sucesivas (R3 = R3 * R1)
        AND R0, R0, #0
        ADD R4, R1, #0
M_LOOP1 
        ADD R4, R4, #0
        BRnz M_END1
        ADD R0, R0, R3
        ADD R4, R4, #-1
        BR M_LOOP1
M_END1  
        ADD R3, R0, #0

        ; División del exponente entre 2 (Shift simulado por restas de 2)
L_SHIFT 
        AND R0, R0, #0
        ADD R4, R2, #0
        AND R2, R2, #0
D_LOOP  
        ADD R4, R4, #-2
        BRn D_END
        ADD R2, R2, #1
        BR D_LOOP
D_END   

        ADD R2, R2, #0
        BRnz POST_PROC

        ; Multiplicación de cuadrados sucesivos (R1 = R1 * R1)
        AND R0, R0, #0
        ADD R4, R1, #0
M_LOOP2 
        ADD R4, R4, #0
        BRnz M_END2
        ADD R0, R0, R1
        ADD R4, R4, #-1
        BR M_LOOP2
M_END2  
        ADD R1, R0, #0

        BR LOOP_W

        ; --- 4. PROCESAMIENTO FINAL Y AJUSTE DE SIGNOS ---
POST_PROC 
        ADD R5, R5, #0
        BRz ST_RES              ; Si la base era positiva, guarda directo
        ADD R6, R6, #0
        BRz ST_RES              ; Si el exponente era par, guarda directo
        
        ; Si base negativa y exponente impar, el resultado final es negativo
        NOT R3, R3
        ADD R3, R3, #1

        ; --- 5. ÚNICO ACCESO A MEMORIA ---
ST_RES  
        ST R3, FINAL_RES        ; Guarda el resultado final en memoria RAM
        HALT                    ; Fin del programa

; --- DATOS ---
FINAL_RES   .BLKW #1

        .END