


.EXTERNAL CIRCLSH-CIRCLSH
sub_circlsh     .FILL CIRCLSH-CIRCLSH


;   ============================================================================
;   Subrutina: DQ16_TO_Q8
;       Convierte entre distintos formatos Q.
;   
;   -> INPUT  [R0] Parte entera del Q15.16 . 
;   -> INPUT  [R1] Parte fraccionaria del Q15.16 .
;   <- OUTPUT [R0] Q7.8 .
;   ============================================================================

;   [.....int......][.....frac.....]
;   ..int..][.....frac.....][.......    (<< 8)
;   [....Q3_12.....][..............]


DQ16_TO_Q8

    ST R1 dq16_to_q8_r1
    ST R2 dq16_to_q8_r2
    ST R3 dq16_to_q8_r3
    ST R7 dq16_to_q8_r7
    
    ; [R0] entero
    ; [R1] decimal
    
    LD R2 dq16_to_q8_n
    LD R3 sub_circlsh
    JSRR R3

    ADD R1 R1 #0
    BRzp dq16_to_q8_ret
    ADD R0 R0 #1

dq16_to_q8_ret
    LD R1 dq16_to_q8_r1
    LD R2 dq16_to_q8_r2
    LD R3 dq16_to_q8_r3
    LD R7 dq16_to_q8_r7
    RET

dq16_to_q8_r1   .FILL #0
dq16_to_q8_r2   .FILL #0
dq16_to_q8_r3   .FILL #0
dq16_to_q8_r7   .FILL #0
dq16_to_q8_n    .FILL #8


.END